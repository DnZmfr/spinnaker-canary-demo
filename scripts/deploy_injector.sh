#!/usr/bin/env bash

kubectl get svc canary-demo-service &>/dev/null && \
kubectl -n default run injector --image=nginx -- /bin/sh -c "while true; do curl -sS --max-time 3 http://canary-demo-service/; done" || \
echo "The injector pod generates traffic on the canary-demo-service. Looks like the spinnaker demo app was not yet deployed. Try again later."
