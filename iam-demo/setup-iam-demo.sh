#!/usr/bin/env bash
# =============================================================
# setup-iam-demo.sh
# Creates a demo Service ID scoped to ONE COS bucket.
# Safe to run in production — creates only a new Service ID.
# Run cleanup.sh after the demo to remove everything.
#
# Usage: ./setup-iam-demo.sh <COS-INSTANCE-ID> <BUCKET-NAME>
# =============================================================

set -euo pipefail

COS_INSTANCE_ID="${1:-}"
BUCKET_NAME="${2:-demo-artifacts-bucket}"

if [[ -z "$COS_INSTANCE_ID" ]]; then
  echo "Usage: $0 <COS-INSTANCE-ID> <BUCKET-NAME>"
  echo ""
  echo "Find your COS instance ID with:"
  echo "  ibmcloud resource service-instance 'Cloud Object Storage-2a' --output json | jq -r '.[0].id'"
  exit 1
fi

echo "=== Creating Service ID: demo-pipeline-id ==="
ibmcloud iam service-id-create demo-pipeline-id \
  --description "RVCE Workshop demo — pipeline identity scoped to one bucket. Created $(date). DELETE AFTER DEMO." \
  2>&1 | grep -E "^(Name|ID|Description|Created)"

echo ""
echo "=== Assigning least-privilege policy (Writer on ONE bucket only) ==="
ibmcloud iam service-id-policy-create demo-pipeline-id \
  --roles Writer \
  --service-name cloud-object-storage \
  --service-instance "$COS_INSTANCE_ID" \
  --resource-type bucket \
  --resource "$BUCKET_NAME"

echo ""
echo "=== Verifying policy — should show Writer on one bucket only ==="
ibmcloud iam service-id-policies demo-pipeline-id

echo ""
echo "=== Setup complete ==="
echo "Service ID 'demo-pipeline-id' created with Writer access on bucket: $BUCKET_NAME"
echo ""
echo "To show in demo:"
echo "  ibmcloud iam service-id demo-pipeline-id"
echo "  ibmcloud iam service-id-policies demo-pipeline-id"
echo ""
echo "REMEMBER: Run cleanup.sh after the demo to delete this service ID."
