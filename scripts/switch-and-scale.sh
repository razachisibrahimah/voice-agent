#!/usr/bin/env bash

NAMESPACE="voice-agent"
SERVICE_NAME="voice-agent-svc"

NEW_COLOR=$1   # blue or green
OLD_COLOR=$2   # green or blue (opposite of NEW_COLOR)

if [[ -z "$NEW_COLOR" || -z "$OLD_COLOR" ]]; then
  echo "Usage: $0 <new-color> <old-color>"
  echo "Example: $0 blue green"
  exit 1
fi

echo "Switching traffic to '$NEW_COLOR' and scaling down '$OLD_COLOR'..."

#  Update the service selector to point to the new deployment
echo "Updating service '$SERVICE_NAME' to route traffic to '$NEW_COLOR' pods..."
kubectl patch service $SERVICE_NAME -n $NAMESPACE \
  --type=json -p="[
    {\"op\": \"replace\", \"path\": \"/spec/selector/role\", \"value\": \"$NEW_COLOR\"}
  ]"

# Wait for new deployment rollout to complete
echo "Waiting for '$NEW_COLOR' deployment to be fully rolled out..."
kubectl rollout status deployment/voice-agent-$NEW_COLOR -n $NAMESPACE

#  Scale down old deployment gracefully
echo "Scaling down old '$OLD_COLOR' deployment to zero replicas (without interrupting active traffic)..."
kubectl scale deployment/voice-agent-$OLD_COLOR -n $NAMESPACE --replicas=0

echo "Traffic is now routed to '$NEW_COLOR' and '$OLD_COLOR' has been scaled down."
