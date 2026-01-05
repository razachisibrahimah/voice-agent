#!/usr/bin/env bash

NAMESPACE="voice-agent"
LABEL="role=blue"

PODS=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
  echo "No blue pods found"
  exit 1
fi

echo "Starting long-running process in blue pods..."

for POD in $PODS; do
  echo "➡️  $POD"
  kubectl exec -n "$NAMESPACE" "$POD" -- sh -c '
    while true; do
      echo "$(date) still alive"
      sleep 30
    done
  ' &
done

echo ""
echo "Loops started in background"
echo "Use: kubectl logs <pod> -n voice-agent to verify"
