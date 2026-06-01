---
inclusion: always
---

# Enterprise DevOps Context

## Platform Overview

| Component | Technology |
|-----------|------------|
| Cloud | AWS |
| IaC | Terraform |
| Application | Spring PetClinic |
| Runtime | Java 17, Spring Boot |
| Deployment | Direct on EC2 (no containers) |

---

## Core Operational Rules

### Infrastructure Management

* All AWS resources **must** be created and managed through Terraform
* Manual AWS Console changes are **prohibited** — all changes require Terraform + GitOps
* Infrastructure must be **idempotent** — `terraform apply` must be safe to run multiple times
* Resources must support **automated remediation** — avoid manual intervention patterns

### Incident Response

* **RCA (Root Cause Analysis) is mandatory** for all incidents
* AI must analyze Terraform code to identify root causes
* All remediation must be **Terraform-only** — no manual console fixes
* After remediation, **Git commit is required** before `terraform apply`

### Monitoring & Validation

* ALB health checks must be monitored via CloudWatch alarms
* All infrastructure changes require **validation testing**
* After `terraform apply`, validate:
  - Target group shows healthy status
  - ALB returns HTTP 200
  - Application UI loads successfully

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
fix: corrected ALB health check path
```

---

## Terraform Standards

### File Organization

* Environment-specific configs: `infrastructure/environments/<env>/`
* Main files: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
* State file: `terraform.tfstate` (managed remotely in production)

### Best Practices

* Use variables for all configurable values — never hardcode
* Reference resources via `aws_resource.name.id` syntax
* Use `depends_on` for explicit resource ordering when needed
* Always include `tags` block with `Name` and `Environment`

### Security

* Never commit `terraform.tfvars` with secrets — use `.gitignore`
* Use `aws_security_group` ingress rules to restrict access
* ALB must expose only HTTP port 80
* EC2 must allow SSH only from specific CIDR blocks

---

## Application Standards

### Spring PetClinic

* **Runtime**: Java 17, Spring Boot
* **Port**: 8080
* **Build**: Maven (`mvn package`)
* **Startup**: Started via EC2 userdata script
* **Health Endpoint**: `/` (root path)

### Expected Behavior

* Application starts on port 8080
* Health check at `/` returns HTTP 200
* No Docker containers — runs directly on EC2

---

## Common Failure Scenarios

| Scenario | Symptom | Root Cause | Remediation |
|----------|---------|------------|-------------|
| Wrong health check path | HTTP 503, targets unhealthy | `health_check_path` mismatch | Update `terraform.tfvars` |
| Wrong target port | Connection timeout | `app_port` misconfiguration | Update `terraform.tfvars` |
| Security group misconfig | Connection refused | EC2 SG blocks ALB | Update `security_groups.tf` |

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

## AI Operational Behavior

Kiro AI responsibilities:

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
* Validate with `curl` commands against ALB DNS

**Do Not:**
* Suggest manual AWS Console changes
* Recommend Docker/containerization for this application
* Skip GitOps workflow for any change
* Omit validation steps from remediation

---

## Demo & Training Objective

This environment is designed for:

* DevOps demonstrations
* AI-assisted troubleshooting
* Terraform remediation demos
* AWS incident analysis
* Infrastructure RCA workflows
* SRE operational simulations
