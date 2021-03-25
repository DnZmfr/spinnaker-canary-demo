#!/usr/bin/env bash

source init.sh

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document| grep "region"| awk -F"\"" '{print $4}')
egrep -q ACCOUNT_ID ~/.bash_profile && sed -i "s|export ACCOUNT_ID.*|export ACCOUNT_ID=${ACCOUNT_ID}|g" ~/.bash_profile || echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
egrep -q AWS_REGION ~/.bash_profile && sed -i "s|export AWS_REGION.*|export AWS_REGION=${AWS_REGION}|g" ~/.bash_profile || echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile

# Create a CMK(custom management key) for the EKS cluster to use when encrypting Kubernetes secrets"
aws kms list-aliases --output text | grep -q "alias/spinnaker" || aws kms create-alias --alias-name alias/spinnaker --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
export MASTER_ARN=$(aws kms describe-key --key-id alias/spinnaker --query KeyMetadata.Arn --output text)
egrep -q MASTER_ARN ~/.bash_profile && sed -i "s|export MASTER_ARN.*|export MASTER_ARN=${MASTER_ARN}|g" ~/.bash_profile || echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

# Generate cluster config yaml for eksctl
cat << EOF > ${HOME}/${EKS_CLUSTER_NAME}.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${EKS_CLUSTER_NAME}
  region: ${AWS_REGION}
  version: "1.19"

availabilityZones: ["${AWS_REGION}a", "${AWS_REGION}b", "${AWS_REGION}c"]

managedNodeGroups:
- name: spinnaker-nodegroup
  desiredCapacity: 2
  instanceType: t2.large
  ssh:
    allow: true
    publicKeyName: deployment

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

bold "Create the kubernetes cluster"
/usr/local/bin/eksctl create cluster -f ${HOME}/${EKS_CLUSTER_NAME}.yaml
rm -f ${HOME}/${EKS_CLUSTER_NAME}.yaml

bold "Wait for the cluster to become active"
aws eks wait cluster-active --name ${EKS_CLUSTER_NAME}

rm -f ${HOME}/${EKS_CLUSTER_NAME}.yaml

bold "Retrieve Amazon EKS cluster kubectl contexts"
rm -f /home/ec2-user/.kube/config
aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region eu-central-1 --alias ${EKS_CLUSTER_NAME}

bold "Deploy Prometheus and Grafana"
kubectl create namespace prometheus
kubectl create namespace grafana
helm install prometheus prometheus-community/prometheus --namespace prometheus
helm install grafana grafana/grafana --namespace grafana --set adminPassword=parola123 --values grafana.yaml --set service.type=LoadBalancer

bold "Prepare Spinnaker"
rm -f ~/.hal/config
rm -rf ~/.hal/default
hal config version edit --version 1.25.3

#Halyard/Spinnaker: Enable the Kubernetes provider"
hal config provider kubernetes enable

bold "Set the current kubectl context to the cluster for Spinnaker"
kubectl config use-context ${EKS_CLUSTER_NAME}

# Assign the Kubernetes context to CONTEXT
export CONTEXT=$(kubectl config current-context)

bold "Create a service account for the Amazon EKS cluster"
kubectl apply --context ${CONTEXT} -f https://www.spinnaker.io/downloads/kubernetes/service-account.yml

#Extract the secret token of the spinnaker-service-account
export TOKEN=$(kubectl get secret --context ${CONTEXT} \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context ${CONTEXT} \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)

bold "Set the user entry in kubeconfig"
kubectl config set-credentials ${CONTEXT}-token-user --token ${TOKEN}
kubectl config set-context ${CONTEXT} --user ${CONTEXT}-token-user

#Add spinnaker-eks as a Kubernetes provider"
hal config provider kubernetes account add ${EKS_CLUSTER_NAME} --context ${CONTEXT}
#Enable artifact support
hal config features edit --artifacts true
#Configure Spinnaker to install in Kubernetes
hal config deploy edit --type distributed --account-name ${EKS_CLUSTER_NAME}
#Configure Spinnaker to use AWS S3
export AWS_ID_ACCESS_KEY=$(grep aws_access_key_id ~/.aws/credentials| awk {'print $NF}')
export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_access_key ~/.aws/credentials| awk {'print $NF}')
hal config storage s3 edit --access-key-id ${AWS_ID_ACCESS_KEY} --secret-access-key ${AWS_SECRET_ACCESS_KEY} --region ${AWS_REGION}
hal config storage edit --type s3 # test

bold "Deploy Spinnaker"
hal deploy apply --wait-for-completion

bold "Expose Spinnaker using Elastic Load Balancer"
kubectl -n ${NAMESPACE} expose service spin-gate --type LoadBalancer --port 80 --target-port 8084 --name spin-gate-public
kubectl -n ${NAMESPACE} expose service spin-deck --type LoadBalancer --port 80 --target-port 9000 --name spin-deck-public

bold "Apply some more Spinnaker config update"
hal config edit --timezone Europe/Berlin
hal config features edit --artifacts-rewrite true
hal config artifact github enable
hal config canary enable
hal config canary prometheus enable
hal config canary prometheus account add my-prometheus --base-url http://prometheus-server.prometheus.svc.cluster.local:80
hal config canary edit --default-metrics-store prometheus
hal config canary edit --default-metrics-account my-prometheus
hal config artifact github account add $GITHUB_ACCOUNT_NAME --token-file $GITHUB_TOKEN_FILE
hal config provider docker-registry enable
hal config provider docker-registry account add $DOCKER_ACCOUNT_NAME --address index.docker.io --repositories dnzmfr/canary-demo --username $DOCKER_ACCOUNT_NAME --email dropsu@gmail.com --password-file $DOCKER_PASS_FILE
export API_URL=$(kubectl -n ${NAMESPACE} get svc spin-gate-public -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export UI_URL=$(kubectl -n ${NAMESPACE} get svc spin-deck-public -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
hal config security api edit --override-base-url http://${API_URL}
hal config security ui edit --override-base-url http://${UI_URL}

bold "Deploy the last spinnaker config updates"
hal deploy apply

bold "Create config for spin cli"
rm -f ${HOME}/.spin/config
mkdir -p ${HOME}/.spin
cat << EOF > ${HOME}/.spin/config
gate:
  endpoint: http://${API_URL}
auth:
  enabled: false
EOF

bold "Done."
