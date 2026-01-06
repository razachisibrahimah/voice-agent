#!/bin/bash

NAMESPACE="voice-agent"
echo "Checking pods and their termination durations in namespace '$NAMESPACE'..."
echo ""

# Get all pods that have deletionTimestamp set
kubectl get pods -n "$NAMESPACE" -o json | jq -r '
  .items[] 
  | select(.metadata.deletionTimestamp != null) 
  | { name: .metadata.name, 
      status: .status.phase, 
      deleted_at: .metadata.deletionTimestamp }' | \
  jq -s '.[]' | while read -r line; do
    if [[ $line == \"name\"* ]]; then
        pod_name=$(echo "$line" | cut -d'"' -f4)
    elif [[ $line == \"status\"* ]]; then
        status=$(echo "$line" | cut -d'"' -f4)
    elif [[ $line == \"deleted_at\"* ]]; then
        deletion_timestamp=$(echo "$line" | cut -d'"' -f4)

        # Format timestamp
        formatted_time=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$deletion_timestamp" +"%Y-%m-%d %H:%M:%S UTC" 2>/dev/null)

        # Fallback in case formatting fails
        if [[ -z "$formatted_time" ]]; then
          formatted_time="$deletion_timestamp"
        fi

        echo "Pod: $pod_name"
        echo "  Status: $status"
        echo "  Deleted at: $formatted_time"

        # Calculate duration since deletion
        deleted_epoch=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$deletion_timestamp" +%s 2>/dev/null)
        now_epoch=$(date +%s)
        if [[ "$deleted_epoch" =~ ^[0-9]+$ ]]; then
          diff=$((now_epoch - deleted_epoch))
          if (( diff >= 0 )); then
            hours=$((diff / 3600))
            minutes=$(((diff % 3600) / 60))
            seconds=$((diff % 60))
            echo "  Time since termination started: ${hours}h:${minutes}m:${seconds}s"
          else
            echo "  Time since termination started: not yet (future timestamp)"
          fi
        else
          echo "  Could not parse deletion time"
        fi
        echo ""
    fi
done
