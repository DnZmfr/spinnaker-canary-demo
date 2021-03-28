# Canary deployment with Spinnaker

This repository contains all the scripts, files and instructions necessary to create the infrastructure and perform a - manual, or automated - canary deployment under 30 minutes.

## Overview

Canary is a deployment process in which a change is partially rolled out, then evaluated against the current deployment (baseline) to ensure that the new deployment is operating at least as well as the old. This evaluation is done using key metrics that are chosen when the canary is configured.

### Tools & Technologies:
* [AWS](https://aws.amazon.com/) - AWS Cloud computing
* [Kubernetes](https://kubernetes.io/) - Container orchestration platform
* [Docker](https://www.docker.com/) - Containerization platform
* [Spinnaker](https://spinnaker.io/) - Continuous delivery software platform
* [MinIO](https://min.io/) - High performance object storage server
* [Prometheus](https://prometheus.io/) - Time-series metrics monitoring tool
* [Grafana](https://aws.amazon.com/) - Observability dashboards for prometheus metrics

### Repo Structure

```
.
|-- LICENSE                                         
|-- README.md                                       
|-- app                                             # directory containing the demo-app source code and sample kubernetes deploy manifest
|   |-- Dockerfile                                  # the app dockerfile used for building new images
|   |-- app.py                                      # app source code
|   `-- sample.yaml                                 # kubernetes deploy manifest
|-- config                                          # directory containing config files
|   |-- grafana                                     # grafana related source
|   |   |-- dashboard.json                          # grafana dashboard for demo-app
|   |   `-- datasource.yaml                         # grafana datasource to prometheus service
|   `-- spinnaker                                   # directory containing spinnaker app, pipelines and canary configs
|       |-- app-demo.json                           # demo-app config
|       |-- config-canary.json                      # canary config
|       |-- pipeline-automated-canary-deploy.json   # automated canary deployment pipeline 
|       |-- pipeline-manual-canary-deploy.json      # manual canary deployment pipeline
|       |-- pipeline-simple-deploy.json             # simple deployment pipeline
|       |-- pipeline-trigger-deploy.json            # docker hub trigger deployment pipeline
|       `-- service-account.yml                     # spinnaker
`-- scripts                                         # directory containing scripts to prepare and deploy infrastructure and app
    |-- init.sh                                     # bash script to initialize required variables used during deployment
    |-- prepare.sh                                  # bash script to install required command lines
    |-- deploy.sh                                   # script to deploy the infrastructure: k8s cluster, prometheus, grafana, spinnaker, minio
    `-- create_spinnaker_app.sh                     # script to creating a spinnaker demo app, canary config and pipelines             
```

## Prerequisites

* An AWS account
* A Docker Hub account
* A Github account
* A linux server for deployment purpose (Amazon Linux, or any other flavour with yum package manager). For this demo I use an AWS EC2 t2.small instance with 1vCPU and 2GiB Memory. 

### Prepare deployment server
```
ssh ec2-user@deploy-server

# some credentials needs to be store in files to be used during deployment
echo -n <github-personal-token> > ${HOME}/.github.tkn
echo -n <docker-hub-password> > ${HOME}/.docker.psw
echo "ACCESS_KEY=minio-access-key" > ${HOME}/.minio.creds
echo "SECRET_KEY=m1nioAcc3s5Key" >> ${HOME}/.minio.creds

# configure awscli
aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: eu-central-1
Default output format [None]: json

#Install git cli
sudo yum -y install git

git config --global user.name your-github-user
git config --global user.email your-fake-github-email@users.noreply.github.com

git clone https://github.com/DnZmfr/spinnaker-canary-demo.git
cd spinnaker-canary-demo/scripts
# Install required command lines
sudo ./prepare.sh
```

Follow these [instruction](https://github.com/DnZmfr/spinnaker-canary-demo/settings/actions/add-new-runner) to add a GitHub action self-hosted runner used for CI/CD purposes.

## Installation

#### Deploy EKS cluster, prometheus, grafana, minio and spinnaker
```
cd spinnaker-canary-demo/scripts
./deploy.sh
```

#### Create spinnaker demo-app, canary config and pipelines
```
./create_spinnaker_app.sh
```
