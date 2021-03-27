#!/usr/bin/env bash

source init.sh

bold "Create a spinnaker demo app"
spin application save --file ../spinnaker/app.json
sleep 5

bold "Create pipelins"
spin pipeline save --file ../spinnaker/pipeline-trigger-deploy.json
spin pipeline save --file ../spinnaker/pipeline-simple-deploy.json
spin pipeline save --file ../spinnaker/pipeline-canary-deploy.json
