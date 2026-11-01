// ============================================================
//  GOOD EXAMPLE — Secrets read from environment at runtime
//  Never hardcode credentials in source code
// ============================================================

// FIXED: Read from environment variables injected at runtime.
// In IBM Cloud Continuous Delivery, these are resolved from
// IBM Cloud Secrets Manager via a pipeline environment property —
// the actual value never appears in source code or build logs.

const IBM_API_KEY = process.env.IBM_API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;

// Validate required secrets are present at startup
if (!IBM_API_KEY || !DB_PASSWORD) {
  console.error("ERROR: Required environment variables not set.");
  console.error("Set IBM_API_KEY and DB_PASSWORD via Secrets Manager.");
  process.exit(1);
}

// FIXED: Never log secret values — log only that they were loaded
console.log("Secrets loaded successfully from environment.");

module.exports = { IBM_API_KEY, DB_PASSWORD };
