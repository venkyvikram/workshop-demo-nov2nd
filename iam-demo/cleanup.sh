#!/usr/bin/env bash
# =============================================================
# cleanup.sh
# Removes everything created by setup-iam-demo.sh
# Run this after the demo session.
# =============================================================

set -euo pipefail

echo "=== Cleaning up RVCE Workshop demo resources ==="

# Check if service ID exists
if ibmcloud iam service-id demo-pipeline-id > /dev/null 2>&1; then
  echo "Deleting policies on demo-pipeline-id..."
  POLICY_IDS=$(ibmcloud iam service-id-policies demo-pipeline-id -o json 2>/dev/null | jq -r '.[].id' 2>/dev/null || echo "")

  if [[ -n "$POLICY_IDS" ]]; then
    while IFS= read -r pid; do
      echo "  Deleting policy: $pid"
      ibmcloud iam service-id-policy-delete demo-pipeline-id "$pid" -f
    done <<< "$POLICY_IDS"
  fi

  echo "Deleting service ID: demo-pipeline-id..."
  ibmcloud iam service-id-delete demo-pipeline-id -f
  echo "Service ID deleted."
else
  echo "Service ID 'demo-pipeline-id' not found — nothing to delete."
fi

echo ""
echo "=== Clean-up complete. Production account restored. ==="
