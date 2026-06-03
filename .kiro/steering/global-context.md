---
inclusion: always
---

# Enterprise DevOps Context

## Platform Overview

| Component | Technology |
|-----------|------------|
| Cloud | AWS |
| IaC | Terraform |
| Application | [Application Name] |
| Runtime | [Runtime Environment] |
| Deployment | [Deployment Method] |

---

## Core Operational Rules

### Infrastructure Management

* All infrastructure resources **must** be created and managed through Terraform
* Manual console changes are **prohibited** — all changes require Terraform + GitOps
* Infrastructure must be **idempotent** — `terraform apply` must be safe to run multiple times
* Resources must support **automated remediation** — avoid manual intervention patterns

### Incident Response

* **RCA (Root Cause Analysis) is mandatory** for all incidents
* AI must analyze Terraform code to identify root causes
* All remediation must be **Terraform-only** — no manual console fixes
* After remediation, **Git commit is required** before `terraform apply`

### Monitoring & Validation

* Health checks must be monitored via CloudWatch alarms
* All infrastructure changes require **validation testing**
* After `terraform apply`, validate:
  - Target group/instances show healthy status
  - Load balancer returns expected HTTP status
  - Application responds correctly

---

## GitOps Standards

All infrastructure changes must follow this workflow:

1. Create a feature branch: `git checkout -b fix/<issue-description>`
2. Make changes in Terraform files only
3. Run `terraform plan` to verify changes
4. Commit with format: `fix: <issue description>`
5. Push branch and create PR/MR
6. After merge, run `terraform apply`
7. Validate the fix with automated or manual tests

**Example commit message:**
```
fix: corrected load balancer health check path
```

---

## Terraform Standards

### File Organization

```
infrastructure/environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── terraform.tfstate
├── staging/
└── prod/
```

* Environment-specific configs: `infrastructure/environments/<env>/`
* Main files: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
* State file: `terraform.tfstate` (managed remotely in production)

### Best Practices

* Use variables for all configurable values — never hardcode
* Reference resources via `aws_resource.name.id` syntax
* Use `depends_on` for explicit resource ordering when needed
* Always include `tags` block with `Name` and `Environment`
* Use `terraform plan` before `terraform apply`

### Security

* Never commit `terraform.tfvars` with secrets — use `.gitignore`
* Use `aws_security_group` ingress rules to restrict access
* Load balancer should expose only required ports
* Backend instances must allow traffic only from load balancer

---

## Application Standards

### Application Overview

* **Runtime**: [Runtime Environment]
* **Port**: [Application Port]
* **Build**: [Build Tool] (`[build_command]`)
* **Startup**: Started via userdata/init script
* **Health Endpoint**: [Health Check Path]

### Expected Behavior

* Application starts on configured port
* Health check returns HTTP 200
* No unexpected dependencies for basic health

---

## Common Failure Scenarios

| Scenario | Symptom | Root Cause | Remediation |
|----------|---------|------------|-------------|
| Wrong health check path | HTTP 503, targets unhealthy | Health check path mismatch | Update `terraform.tfvars` |
| Wrong target port | Connection timeout | Application port misconfiguration | Update `terraform.tfvars` |
| Security group misconfig | Connection refused | Backend SG blocks LB ingress | Update `security_groups.tf` |

---

## RCA Expectations

When investigating incidents, AI must generate:

1. **Incident Summary** — What's broken and impact
2. **Root Cause** — Why it happened (Terraform analysis)
3. **Impact Analysis** — Affected users/services
4. **Terraform Fix** — Specific code changes needed
5. **Validation Steps** — How to verify the fix
6. **Preventive Recommendation** — How to avoid recurrence

---

## Script Execution Rule

**NEVER run any script or Terraform command automatically** unless the user explicitly asks to run it.

- If the user says "fix", "update", "change", "correct" → make the code changes only, do NOT deploy or run scripts
- If the user says "deploy", "apply", "run", "execute" → then run the appropriate script
- Always wait for explicit instruction before executing any command

---

## Deploy Working Directory Rule

Whenever any deploy-related action is requested (e.g. "deploy the infrastructure", "deploy the infra", "apply", "provision"), the AI **must**:

1. **Always** run `bash deploy.sh` from `D:\Workspace\petclinic\scripts`
2. Never run `terraform apply` directly — always go through `deploy.sh`
3. Never run deploy scripts from a different directory unless explicitly instructed

Whenever any destroy-related action is requested (e.g. "destroy the infrastructure", "destroy the infra", "tear down"), the AI **must**:

1. **Always** run `bash destroy.sh` from `D:\Workspace\petclinic\scripts`
2. Never run `terraform destroy` directly — always go through `destroy.sh`

### Script Reference

| Action | Trigger Phrases | Script | Command |
|--------|----------------|--------|---------|
| Deploy / Apply | "deploy", "provision", "apply", "deploy infra", "deploy the infrastructure" | `deploy.sh` | `bash deploy.sh` (cwd: `D:\Workspace\petclinic\scripts`) |
| Destroy | "destroy", "tear down", "destroy infra", "destroy the infrastructure" | `destroy.sh` | `bash destroy.sh` (cwd: `D:\Workspace\petclinic\scripts`) |
| Validate | "validate", "check infra" | `validate.sh` | `bash validate.sh` (cwd: `D:\Workspace\petclinic\scripts`) |

**Example:**
```bash
cd D:\Workspace\petclinic\scripts
bash deploy.sh
```

For direct Terraform commands (`terraform plan`, `terraform init`), navigate to the environment directory:
```bash
cd D:\Workspace\petclinic\infrastructure\environments\dev
terraform plan
```

---

## AI Operational Behavior

AI responsibilities:

* Analyze Terraform code for misconfigurations
* Detect infrastructure drift from expected state
* Investigate outages using RCA methodology
* Generate Terraform-only remediation plans
* Validate infrastructure recovery after fixes
* Recommend preventive improvements

**Do:**
* Reference actual Terraform file paths
* Use exact variable names from `variables.tf`
* Include specific `terraform plan` and `terraform apply` commands
* Validate with appropriate test commands against service endpoint

**Do Not:**
* Suggest manual console changes
* Skip GitOps workflow for any change
* Omit validation steps from remediation
* Modify state files directly

---

## New Relic Log Querying

### Key Types — Critical Distinction

| Key | Variable | Prefix | Purpose |
|-----|----------|--------|---------|
| Ingest / License Key | `newrelic_license_key` | `NRAL-...` | **Send** logs/metrics TO New Relic (write-only) |
| User API Key | `newrelic_user_api_key` | `NRAK-...` | **Query** logs/metrics FROM New Relic (read) |

### When User Asks for New Relic Logs

When the user says "get logs from New Relic", "fetch New Relic logs", or any variation:

1. Read `infrastructure/environments/dev/terraform.tfvars`
2. Look for `newrelic_user_api_key` (starts with `NRAK-`) — this is the query key
3. Read `newrelic_account_id` from the same file
4. Query via New Relic GraphQL API using PowerShell:

```powershell
$headers = @{ "API-Key" = "<NRAK-key>"; "Content-Type" = "application/json" }
$body = '{"query":"{ actor { account(id: <account_id>) { nrql(query: \"FROM Log SELECT message, logGroup, timestamp WHERE logGroup LIKE \\u0027petclinic/%\\u0027 SINCE 30 minutes ago LIMIT 20\") { results } } } }"}'
Invoke-RestMethod -Uri "https://api.newrelic.com/graphql" -Method POST -Headers $headers -Body $body
```

### Log Groups Available

| Log Group | Contents |
|-----------|----------|
| `petclinic/application-logs` | Spring Boot application logs |
| `petclinic/userdata-logs` | EC2 startup / setup script logs |
| `petclinic/apache-access-logs` | Apache HTTP access logs |
| `petclinic/apache-error-logs` | Apache HTTP error logs |

### NRQL Query Examples

```sql
-- All petclinic logs (last 30 min)
FROM Log SELECT message, logGroup, timestamp
WHERE logGroup LIKE 'petclinic/%'
SINCE 30 minutes ago LIMIT 50

-- Application logs only
FROM Log SELECT message, timestamp
WHERE logGroup = 'petclinic/application-logs'
SINCE 1 hour ago LIMIT 50

-- Error logs only
FROM Log SELECT message, timestamp
WHERE logGroup LIKE 'petclinic/%' AND message LIKE '%ERROR%'
SINCE 1 hour ago LIMIT 20
```

### If NRAK key is missing
- Ask the user: "Please add your New Relic User API key (`NRAK-...`) to `terraform.tfvars` as `newrelic_user_api_key`"
- The ingest key (`NRAL-...`) cannot be used for querying — they are different keys
- User API key location: [one.newrelic.com](https://one.newrelic.com) → top-right name → API Keys → Create key (type: User)

---

## Demo & Training Objective

This environment is designed for:

* DevOps demonstrations
* AI-assisted troubleshooting
* Terraform remediation demos
* Cloud infrastructure incident analysis
* Infrastructure RCA workflows
* SRE operational simulations