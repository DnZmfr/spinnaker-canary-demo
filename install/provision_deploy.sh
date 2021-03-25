#!/usr/bin/env bash

source init.sh

if [ ! -f /usr/local/bin/kubectl ]; then
  bold "Installing kubectl cli..."
  curl -o /usr/local/bin/kubectl -sLO https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
  chmod +x /usr/local/bin/kubectl
else
  bold "kubectl cli already installed."
fi

if [ ! -f /usr/local/bin/aws-iam-authenticator ]; then
  bold "Installing aws-iam-authenticator cli..."
  curl -o /usr/local/bin/aws-iam-authenticator -sLO https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
  chmod +x /usr/local/bin/aws-iam-authenticator
else
  bold "aws-iam-authenticator cli already installed."
fi

bold "Installing awscli..."
pip3 install awscli --upgrade --user

if [ ! -f /usr/local/bin/eksctl ]; then
  bold "Installing eksctl cli..."
  curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin/
  chmod +x /usr/local/bin/eksctl
  rm -f eksctl_$(uname -s)_amd64.tar.gz
else
  bold "eksctl cli already installed."
fi

if [ ! -f /usr/local/bin/hal ]; then
  bold "Installing Halyard..."
  curl -sO https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
  bash InstallHalyard.sh -y --user ci_cd
else
  bold "Halyard cli already installed."
fi

if [ ! -f /usr/local/bin/spin ]; then
  bold "Installing spin cli..."
  curl -o /usr/local/bin/spin -sLO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin
  chmod +x /usr/local/bin/spin
else
  bold "spin cli already installed."
fi

if [ ! -f /usr/bin/docker ]; then
  bold "Installing docker..."
  yum install -y docker
else
  bold "docker  already installed."
fi

### Setup github runner
#mkdir actions-runner && cd actions-runner
#curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-osx-x64-2.277.1.tar.gz
#tar xzf ./actions-runner-osx-x64-2.277.1.tar.gz
#./config.sh --url https://github.com/DnZmfr/spinnaker-canary-demo --token XXXXXXXXXXXXXXXXXXXXXXXX
#sudo ./svc.sh install
#sudo ./svc.sh start
