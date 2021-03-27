#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}") && source init.sh

bold "Create a spinnaker demo app"
spin application save --file ../config/spinnaker/app-demo.json
sleep 5

bold "Create canary config"
spin canary canary-config save -f ../config/spinnaker/config-canary.json

bold "Create trigger deploy pipeline"
spin pipeline save --file ../config/spinnaker/pipeline-trigger-deploy.json

bold "Create simple deploy pipeline"
spin pipeline save --file ../config/spinnaker/pipeline-simple-deploy.json

bold "Create canary deploy pipeline"
spin pipeline save --file ../config/spinnaker/pipeline-manual-canary-deploy.json

# Before we create the automated canary pipeline, we need to replace the SIMPLE_DEPLOY_PIPELINE_ID with
# the actual ID of the "Simple deploy" pipeline and CANARY_CONFIG_ID with the ID of our canary config.
export SIMPLE_DEPLOY_PIPELINE_ID=$(spin pipelines get -a canary-demo-app -n "Simple deploy" -o jsonpath="{.id}")
export CANARY_CONFIG_ID=$(spin canary canary-config list -o jsonpath="{[0].id}")
sed -i.orig "s/SIMPLE_DEPLOY_PIPELINE_ID/$SIMPLE_DEPLOY_PIPELINE_ID/g" ../config/spinnaker/pipeline-automated-canary.json
sed -i "s/CANARY_CONFIG_ID/$CANARY_CONFIG_ID/g" ../config/spinnaker/pipeline-automated-canary.json

bold "Create automated canary deploy pipeline"
spin pipeline save --file ../config/spinnaker/pipeline-automated-canary.json
mv ../config/spinnaker/pipeline-automated-canary.json.orig ../config/spinnaker/pipeline-automated-canary.json
