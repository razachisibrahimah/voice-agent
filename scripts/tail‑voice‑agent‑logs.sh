#!/usr/bin/env bash

NAMESPACE="voice-agent"
LABEL="app=voice-agent"

echo "Fetching all pods with label '$LABEL' in namespace '$NAMESPACE'..."
PODS=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
  echo "No pods found matching label."
  exit 1
fi

echo "Tailing logs for the following pods (press Ctrl+C to stop):"
for pod in $PODS; do
  echo "- $pod"
done
echo ""

# Tail logs with pod headers
kubectl logs -n "$NAMESPACE" -l "$LABEL" -f --prefix=true --all-containers=true --max-log-requests=10
