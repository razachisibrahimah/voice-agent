#!/usr/bin/env bash

NAMESPACE="voice-agent"

echo "Checking pods and their terminating durations in namespace '$NAMESPACE'..."
echo ""

# List all pods with status
kubectl get pods -n "$NAMESPACE" -o json | jq -r '
  .items[] |
  {
    name: .metadata.name,
    status: .status.phase,
    startTime: .status.startTime,
    deletionTimestamp: .metadata.deletionTimestamp
  } |
  "\(.name)\t\(.status)\t\(.startTime)\t\(.deletionTimestamp)"
' | while IFS=$'\t' read -r podName status startTime deletionTimestamp; do

  if [[ "$status" == "Terminating" || "$deletionTimestamp" != "null" ]]; then
    # Use `date` to compute age in seconds since deletionTimestamp
    termEpoch=$(date -d "$deletionTimestamp" +%s)
    nowEpoch=$(date +%s)
    diff=$(( nowEpoch - termEpoch ))

    human=$(printf '%02dh:%02dm:%02ds\n' $((diff/3600)) $(((diff%3600)/60)) $((diff%60)))

    echo "Pod: $podName"
    echo "  Status: $status"
    echo "  Deleted at: $deletionTimestamp"
    echo "  Time since termination started: $human"
    echo ""
  fi

done
