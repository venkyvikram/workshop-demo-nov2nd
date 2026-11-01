#!/usr/bin/env bash
# =============================================================
# secrets-demo.sh
# Demonstrates reading a secret from IBM Cloud Secrets Manager
# at runtime — no hardcoded values anywhere.
#
# PRE-REQUISITES:
#   ibmcloud CLI logged in as demo-pipeline-id service ID
#   jq installed (brew install jq)
# =============================================================

set -euo pipefail

SM_INSTANCE_ID="${SM_INSTANCE_ID:-}"
SECRET_ID="${SECRET_ID:-}"
REGION="${REGION:-us-south}"

if [[ -z "$SM_INSTANCE_ID" || -z "$SECRET_ID" ]]; then
  echo "ERROR: Set SM_INSTANCE_ID and SECRET_ID environment variables first."
  exit 1
fi

echo "=== Step 1: Exchange service ID API key for short-lived IAM token ==="
IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')
echo "IAM token obtained (short-lived — expires in 1 hour)"
echo "Token prefix: ${IAM_TOKEN:0:20}..."

echo ""
echo "=== Step 2: Read secret from Secrets Manager ==="
SM_ENDPOINT="https://${SM_INSTANCE_ID}.${REGION}.secrets-manager.appdomain.cloud"

SECRET_RESPONSE=$(curl -s -X GET \
  "${SM_ENDPOINT}/api/v2/secrets/${SECRET_ID}" \
  -H "Authorization: ${IAM_TOKEN}" \
  -H "Accept: application/json")

SECRET_NAME=$(echo "$SECRET_RESPONSE" | jq -r '.name')
echo "Secret name:  $SECRET_NAME"
echo "Secret value: [REDACTED — injected into env, never logged]"

echo ""
echo "=== Step 3: Inject into environment for the app ==="
# In a real pipeline this would be: export IBM_API_KEY="$(echo $SECRET_RESPONSE | jq -r '.payload')"
echo "export IBM_API_KEY=[value from Secrets Manager]  # injected at runtime"

echo ""
echo "=== Done — secret was read, never stored in code or logs ==="
