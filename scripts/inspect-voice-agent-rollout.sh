#!/bin/bash

NAMESPACE="voice-agent"
SERVICE_NAME="voice-agent-svc"
APP_LABEL="voice-agent"

echo "Fetching active pods behind service '$SERVICE_NAME' in namespace '$NAMESPACE'..."
echo ""

# Get IPs of pods in the service endpoint (actively receiving traffic)
POD_IPS=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$POD_IPS" ]; then
  echo "No active pods found behind the service."
else
  echo "Active pod IPs: $POD_IPS"
  echo ""

  echo "Mapping IPs to active pod names..."
  for ip in $POD_IPS; do
    POD_NAME=$(kubectl get pods -n $NAMESPACE -o wide --field-selector=status.phase=Running | grep "$ip" | awk '{print $1}')
    echo "Active pod receiving traffic: $POD_NAME (IP: $ip)"
  done
fi

echo ""
echo "Checking for pods scheduled for termination after rollout..."
echo ""

# Get current ReplicaSet for deployment
CURRENT_RS=$(kubectl get rs -n $NAMESPACE -l app=$APP_LABEL --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}')

echo "Most recent ReplicaSet: $CURRENT_RS"
echo ""

# List all pods with their ReplicaSet (pod-template-hash)
kubectl get pods -n $NAMESPACE -l app=$APP_LABEL -o wide | while read -r line; do
  if [[ "$line" == NAME* ]]; then continue; fi
  POD_NAME=$(echo "$line" | awk '{print $1}')
  POD_IP=$(echo "$line" | awk '{print $6}')
  RS_HASH=$(echo "$POD_NAME" | grep -o '[^-]*$')
  POD_STATUS=$(kubectl get pod "$POD_NAME" -n $NAMESPACE -o jsonpath='{.status.phase}')

  if [[ ! " $POD_IPS " =~ " $POD_IP " ]]; then
    if [[ "$RS_HASH" != "${CURRENT_RS##*-}" && ("$POD_STATUS" == "Running" || "$POD_STATUS" == "Terminating") ]]; then
      echo "Pod scheduled for termination (old ReplicaSet): $POD_NAME (IP: $POD_IP, Status: $POD_STATUS)"
    else
      echo "Inactive pod: $POD_NAME (IP: $POD_IP, Status: $POD_STATUS)"
    fi
  fi
done
