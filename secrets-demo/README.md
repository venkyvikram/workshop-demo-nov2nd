# Secrets Manager Demo

Shows how IBM Cloud Secrets Manager replaces hardcoded credentials.

## The Problem (bad-commit pattern)
```js
const IBM_API_KEY = "AbCd1234-xxxx-hardcoded-in-source";  // ❌ NEVER
```

## The Solution — IBM Cloud Secrets Manager

### Step 1: Store the secret (done once by a human operator)
```bash
# Authenticate
ibmcloud login

# Store the secret in Secrets Manager
ibmcloud secrets-manager secret-create \
  --secret-type arbitrary \
  --name "demo-pipeline-api-key" \
  --description "API key for demo pipeline — rotate every 90 days" \
  --payload "the-actual-secret-value-goes-here" \
  --instance-crn "<your-secrets-manager-instance-crn>"
```

### Step 2: Pipeline reads the secret at runtime (automated)
```bash
# The pipeline service ID has Reader access on this ONE secret only
# It exchanges its own API key for a short-lived IAM token:
export IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')

# Then reads the secret using the IAM token:
SECRET_VALUE=$(curl -s -X GET \
  "https://<instance-id>.us-south.secrets-manager.appdomain.cloud/api/v2/secrets/<secret-id>" \
  -H "Authorization: $IAM_TOKEN" \
  -H "Accept: application/json" | jq -r '.payload')

# Inject into environment — never store in a variable longer than needed
export IBM_API_KEY="$SECRET_VALUE"
```

### Step 3: App reads from environment — no secret in code
```js
const IBM_API_KEY = process.env.IBM_API_KEY;  // ✅ CORRECT
```

## Key Points for Demo
- The secret value **never appears in source code or git history**
- The pipeline **service ID** only has `SecretsReader` role on this one secret
- If the pipeline is compromised, the attacker can only read this one secret
- Secret is **rotated** every 90 days — old value automatically expires
- Every read is **audited** in IBM Cloud Activity Tracker

## IBM Cloud Secrets Manager — what to show on screen
1. Open: https://cloud.ibm.com → Resource list → `sm-projects-nonprod`
2. Navigate to **Secrets** → show the secret exists, name is visible, **value is hidden**
3. Show **Access** tab → only the pipeline service ID has access
4. Show **Activity** tab → every read is logged with timestamp and identity
