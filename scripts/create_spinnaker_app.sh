#!/usr/bin/env bash

source init.sh

bold "Create a spinnaker demo app"
spin application save --file ../spinnaker/app.json
sleep 5

bold "Create canary config"
spin canary canary-config save -f ../spinnaker/canary-config.json

bold "Create trigger deploy pipeline"
spin pipeline save --file ../spinnaker/pipeline-trigger-deploy.json

bold "Create simple deploy pipeline"
spin pipeline save --file ../spinnaker/pipeline-simple-deploy.json

bold "Create canary deploy pipeline"
spin pipeline save --file ../spinnaker/pipeline-canary-deploy.json

# Before we create the automated canary pipeline, we need to replace the SIMPLE_DEPLOY_PIPELINE_ID with
# the actual ID of the "Simple deploy" pipeline and CANARY_CONFIG_ID with the ID of our canary config.
export SIMPLE_DEPLOY_PIPELINE_ID=$(spin pipelines get -a canary-demo-app -n "Simple deploy" -o jsonpath="{.id}")
export CANARY_CONFIG_ID=$(spin canary canary-config list -o jsonpath="{[0].id}")
sed -i "s/SIMPLE_DEPLOY_PIPELINE_ID/$SIMPLE_DEPLOY_PIPELINE_ID/g" ../spinnaker/pipeline-automated-canary.json
sed -i "s/CANARY_CONFIG_ID/$CANARY_CONFIG_ID/g" ../spinnaker/pipeline-automated-canary.json

bold "Create automated canary deploy pipeline"
spin pipeline save --file ../spinnaker/pipeline-automated-canary.json
git restore ../spinnaker/pipeline-automated-canary.json

