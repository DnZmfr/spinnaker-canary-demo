#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export EKS_CLUSTER_NAME=spinnaker-eks
export NAMESPACE=spinnaker

# github credentials
if [ ! -f ~/.github.tkn ]; then
  echo "github.tkn file is missing."
  exit 1
elif [ ! -s ~/.github.tkn ]; then
  echo "github.tkn file is empty. token missing."
  exit 1
else
  export GITHUB_ACCOUNT_NAME=dnzmfr
  export GITHUB_TOKEN_FILE=~/.github.tkn
fi

# docker credentials
if [ ! -f ~/.docker.psw ]; then
  echo "docker.psw file is missing."
  exit 1
elif [ ! -s ~/.docker.psw ]; then
  echo "docker.psw file is empty. password missing."
  exit 1
else
  export DOCKER_ACCOUNT_NAME=dnzmfr
  export DOCKER_PASS_FILE=~/.docker.psw
fi

# aws credentials
if [ ! -f ~/.aws/credentials ]; then
  echo "aws credentials file is missing."
elif [ ! -s ~/.aws/credentials ]; then
  echo "aws credentials file is empty."
else
  export AWS_ID_ACCESS_KEY=$(grep aws_access_key_id ~/.aws/credentials| awk '{print $NF}')
  export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_access_key ~/.aws/credentials| awk '{print $NF}')
fi

# minio credentials
if [ ! -f ~/.minio.creds ]; then
  echo "docke file is missing."
elif [ ! -s ~/.minio.creds ]; then
  echo "minio.creds file is empty. credentials missing."
else
  export MINIO_ACCESS_KEY=$(grep ACCESS_KEY ~/.minio.creds| awk -F"=" '{print $2}')
  export MINIO_SECRET_KEY=$(grep SECRET_KEY ~/.minio.creds| awk -F"=" '{print $2}')
fi
