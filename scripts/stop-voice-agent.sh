#!/usr/bin/env bash

NAMESPACE="voice-agent"

echo "Scaling down all voice-agent deployments in '$NAMESPACE'..."

kubectl scale deployment/voice-agent-blue --replicas=0 -n $NAMESPACE
kubectl scale deployment/voice-agent-green --replicas=0 -n $NAMESPACE

echo "All voice-agent deployments have been scaled down."
