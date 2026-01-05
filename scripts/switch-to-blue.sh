#!/bin/bash

NAMESPACE="voice-agent"
SERVICE_NAME="voice-agent-svc"
CURRENT_COLOR="green"
NEW_COLOR="blue"

echo "Switching traffic from $CURRENT_COLOR to $NEW_COLOR..."

# Patch service to point to the new color
kubectl patch service $SERVICE_NAME -n $NAMESPACE \
  --type=json -p="[
    {\"op\": \"replace\", \"path\": \"/spec/selector/role\", \"value\": \"$NEW_COLOR\"}
  ]"

if [ $? -eq 0 ]; then
  echo "Service selector updated to point to '$NEW_COLOR' pods."

  echo "Waiting for $NEW_COLOR deployment to be ready..."
  kubectl rollout status deployment/voice-agent-$NEW_COLOR -n $NAMESPACE

  echo "Live traffic is now routed to '$NEW_COLOR'."
else
  echo "Failed to patch the service."
  exit 1
fi
