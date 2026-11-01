# IAM Least-Privilege Demo

Shows a Service ID scoped to **exactly one resource** — making the blast radius of any
key exposure minimal.

## What we create

```
Service ID:  demo-pipeline-id
Policy:      Writer on ONE specific COS bucket
             NOT the whole COS instance, NOT the whole account
```

## CLI Commands — Run These Live

### Create the Service ID
```bash
ibmcloud iam service-id-create demo-pipeline-id \
  --description "Demo: pipeline identity for RVCE workshop — scoped to one bucket"
```

### Show the Service ID
```bash
ibmcloud iam service-id demo-pipeline-id
```

### Assign a least-privilege policy (Writer on ONE bucket only)
```bash
# Replace <COS-INSTANCE-ID> and <BUCKET-NAME> with your values
ibmcloud iam service-id-policy-create demo-pipeline-id \
  --roles Writer \
  --service-name cloud-object-storage \
  --service-instance <COS-INSTANCE-ID> \
  --resource-type bucket \
  --resource <BUCKET-NAME>
```

### Show the policy — prove it's scoped
```bash
ibmcloud iam service-id-policies demo-pipeline-id
```
Expected output:
```
Roles:     Writer
Resources:
  Service Name:       cloud-object-storage
  Service Instance:   <COS-INSTANCE-ID>
  Resource Type:      bucket
  Resource:           demo-artifacts-bucket
```

### Try to exceed the scope — this FAILS
```bash
# Create a temp API key for the service ID
ibmcloud iam service-api-key-create demo-temp-key demo-pipeline-id \
  --description "Temp key for scope demo"

# Try to list ALL buckets — should be DENIED
ibmcloud cos buckets --ibmcloud-api-key <KEY-VALUE> 2>&1
# Output: FAILED You do not have permission to list all buckets.

# Try to write to the ALLOWED bucket — should SUCCEED
# (skipped in live demo to keep it clean)

# Clean up temp key
ibmcloud iam service-api-key-delete demo-temp-key demo-pipeline-id -f
```

### Key point to say on screen
> "Even if this key leaked — stolen from a log, a commit, anywhere —
>  the attacker can only write to this one bucket.
>  They cannot read from it, cannot touch any other service,
>  cannot modify IAM. That is least privilege in action."

## Clean Up After the Demo
```bash
# Delete all policies first
ibmcloud iam service-id-policies demo-pipeline-id -o json | \
  jq -r '.[].id' | \
  xargs -I{} ibmcloud iam service-id-policy-delete demo-pipeline-id {} -f

# Delete the service ID
ibmcloud iam service-id-delete demo-pipeline-id -f

echo "Clean-up complete."
```
