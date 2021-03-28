#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

if [ $USER != "root" ]; then
  bold "This script should be executed as root."
  exit 1
fi

if [ ! -f /usr/local/bin/kubectl ]; then
  bold "Install kubectl cli..."
  curl -o /usr/local/bin/kubectl -sLO https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
  chmod +x /usr/local/bin/kubectl
else
  bold "kubectl cli already installed."
fi

if [ ! -f /usr/local/bin/k9s ]; then
  bold "Install k9s cli..."
  curl -sLO https://github.com/derailed/k9s/releases/latest/download/k9s_$(uname -s)_$(uname -m).tar.gz
  tar xf k9s_$(uname -s)_$(uname -m).tar.gz k9s
  rm -f k9s_$(uname -s)_$(uname -m).tar.gz
  mv k9s /usr/local/bin/
else
  bold "k9s cli already installed."
fi

if [ ! -f /usr/local/bin/aws-iam-authenticator ]; then
  bold "Install aws-iam-authenticator cli..."
  curl -o /usr/local/bin/aws-iam-authenticator -sLO https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
  chmod +x /usr/local/bin/aws-iam-authenticator
else
  bold "aws-iam-authenticator cli already installed."
fi

bold "Install awscli..."
yum install -y python3-pip
pip3 install awscli --upgrade --user

if [ ! -f /usr/local/bin/eksctl ]; then
  bold "Install eksctl cli..."
  curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin/
  chmod +x /usr/local/bin/eksctl
  rm -f eksctl_$(uname -s)_amd64.tar.gz
else
  bold "eksctl cli already installed."
fi

bold "Install java..."
yum install -y java-11-amazon-corretto.x86_64

if [ ! -f /usr/local/bin/hal ]; then
  bold "Install Halyard..."
  curl -sO https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
  bash InstallHalyard.sh -y --user ec2-user
  rm -f InstallHalyard.sh
else
  bold "Halyard cli already installed."
fi

if [ ! -f /usr/local/bin/spin ]; then
  bold "Install spin cli..."
  curl -o /usr/local/bin/spin -sLO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin
  chmod +x /usr/local/bin/spin
else
  bold "spin cli already installed."
fi

if [ ! -f /usr/bin/docker ]; then
  bold "Install docker..."
  yum install -y docker
  systemctl enable docker
  systemctl start docker
else
  bold "docker  already installed."
fi

if [ ! -f /usr/local/bin/helm ]; then
  bold "Install helm cli and add some repos..."
  curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
else
  bold "helm cli already installed."
fi

