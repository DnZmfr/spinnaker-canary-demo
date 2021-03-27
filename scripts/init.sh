#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export EKS_CLUSTER_NAME=spinnaker-eks
export NAMESPACE=spinnaker

# github credentials
if [ ! -f ${HOME}/.github.tkn ]; then
  echo "github.tkn file is missing."
  exit 1
elif [ ! -s ${HOME}/.github.tkn ]; then
  echo "github.tkn file is empty. token missing."
  exit 1
else
  export GITHUB_ACCOUNT_NAME=dnzmfr
  export GITHUB_TOKEN_FILE=${HOME}/.github.tkn
fi

# docker credentials
if [ ! -f ${HOME}/.docker.psw ]; then
  echo "docker.psw file is missing."
  exit 1
elif [ ! -s ${HOME}/.docker.psw ]; then
  echo "docker.psw file is empty. password missing."
  exit 1
else
  export DOCKER_ACCOUNT_NAME=dnzmfr
  export DOCKER_PASS_FILE=${HOME}/.docker.psw
fi

# aws credentials
if [ ! -f ${HOME}/.aws/credentials ]; then
  echo "aws credentials file is missing."
elif [ ! -s ${HOME}/.aws/credentials ]; then
  echo "aws credentials file is empty."
else
  export AWS_ID_ACCESS_KEY=$(grep aws_access_key_id ${HOME}/.aws/credentials| awk '{print $NF}')
  export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_access_key ${HOME}/.aws/credentials| awk '{print $NF}')
fi

# minio credentials
if [ ! -f ${HOME}/.minio.creds ]; then
  echo "docke file is missing."
elif [ ! -s ${HOME}/.minio.creds ]; then
  echo "minio.creds file is empty. credentials missing."
else
  export MINIO_ACCESS_KEY=$(grep ACCESS_KEY ${HOME}/.minio.creds| awk -F"=" '{print $2}')
  export MINIO_SECRET_KEY=$(grep SECRET_KEY ${HOME}/.minio.creds| awk -F"=" '{print $2}')
fi
