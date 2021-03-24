#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export EKS_CLUSTER_NAME=spinnaker-eks
export NAMESPACE=spinnaker
export GITHUB_ACCOUNT_NAME=dnzmfr
export GITHUB_TOKEN_FILE=/home/ec2-user/.github.tkn
export DOCKER_ACCOUNT_NAME=dnzmfr
export DOCKER_PASS_FILE=/home/ec2-user/.docker.psw
