---
inclusion: always
---

# Terraform Infrastructure Context

## Platform Overview

| Component | Technology |
|-----------|------------|
| Cloud | AWS |
| IaC | Terraform |
| Application | Spring PetClinic |
| Runtime | Java 17, Spring Boot |
| Deployment | Direct on EC2 (no containers) |

---

## Infrastructure Components

| Component | Terraform Resource | Description |
|-----------|-------------------|-------------|
| VPC | `aws_vpc` | Main VPC for infrastructure |
| Public Subnets | `aws_subnet` | Two public subnets across AZs |
| Route Tables | `aws_route_table` | Routes for public subnets |
| Internet Gateway | `aws_internet_gateway` | Internet connectivity |
| Security Groups | `aws_security_group` | Network ACLs for ALB and EC2 |
| EC2 Instances | `aws_instance` | Application servers |
| ALB | `aws_lb` | Application Load Balancer |
| Target Groups | `aws_lb_target_group` | Health check and routing |
| Listener Rules | `aws_lb_listener` | Traffic routing rules |

---

## Terraform Standards

### Infrastructure Rules

* All AWS resources **must** be created through Terraform
* Manual AWS Console changes are **prohibited**
* Infrastructure changes must be **idempotent**
* Resources must support **automated remediation**
* State files must be stored remotely in production

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

### Best Practices

* Use variables for all configurable values — never hardcode
* Reference resources via `aws_resource.name.id` syntax
* Use `depends_on` for explicit resource ordering when needed
* Always include `tags` block with `Name` and `Environment`
* Use `terraform plan` before `terraform apply`

---

## Networking Standards

### ALB Configuration

| Setting | Value |
|---------|-------|
| Listener Port | 80 (HTTP) |
| Target Port | 8080 (EC2) |
| Health Check Path | `/` |
| Health Check Protocol | HTTP |

**Rules:**
* ALB must expose HTTP port 80
* ALB forwards traffic to EC2 port 8080
* Target groups must use health checks
* Health checks must validate actual application endpoints

### Security Group Rules

#### ALB Security Group

| Direction | Port | Protocol | Source | Description |
|-----------|------|----------|--------|-------------|
| Inbound | 80 | TCP | 0.0.0.0/0 | HTTP from internet |
| Outbound | All | All | 0.0.0.0/0 | All outbound |

**Denied:**
* Direct SSH access to ALB

#### EC2 Security Group

| Direction | Port | Protocol | Source | Description |
|-----------|------|----------|--------|-------------|
| Inbound | 8080 | TCP | ALB SG ID | From ALB only |
| Inbound | 22 | TCP | Configured CIDR | SSH for troubleshooting |
| Outbound | All | All | 0.0.0.0/0 | All outbound |

---

## Application Standards

### Spring PetClinic

| Setting | Value |
|---------|-------|
| Runtime | Java 17 |
| Framework | Spring Boot |
| Build Tool | Maven |
| Port | 8080 |
| Health Endpoint | `/` |
| Deployment | Direct on EC2 |

**Startup:**
* Application started through EC2 userdata script
* No Docker containers used
* Maven builds artifact locally on EC2

**Expected Behavior:**
* Application starts on port 8080
* Health check at `/` returns HTTP 200
* No external dependencies required for basic health

---

## Incident Investigation Rules

When application is unavailable, AI must validate:

1. **ALB listener configuration** — Port 80, protocol HTTP
2. **Target group health** — Check `UnHealthyHostCount` metric
3. **Health check path** — Must match `/` endpoint
4. **EC2 application availability** — SSH and `curl localhost:8080`
5. **Security group rules** — EC2 allows port 8080 from ALB SG
6. **Route table configuration** — Public subnets route to IGW
7. **Terraform resource dependencies** — Verify `depends_on` and references

---

## Common Failure Scenarios

| Scenario | Symptom | Root Cause | Remediation |
|----------|---------|------------|-------------|
| Wrong health check path | HTTP 503, targets unhealthy | `health_check_path` variable mismatch | Update `terraform.tfvars` → `health_check_path = "/"` |
| Wrong target port | Connection timeout | `app_port` misconfiguration | Update `terraform.tfvars` → `app_port = 8080` |
| Security group misconfig | Connection refused | EC2 SG blocks ALB ingress | Update `security_groups.tf` → allow port 8080 from ALB SG |
| Route table misconfig | No internet access | Missing IGW route | Update `vpc.tf` → add route to IGW |
| UserData failure | App not starting | Script errors | Check `userdata.sh` and EC2 logs |

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

## Terraform Remediation Rules

When fixing infrastructure:

**Do:**
* Modify Terraform files only
* Use `terraform plan` before `terraform apply`
* Preserve resource integrity — avoid `replace` when possible
* Update `terraform.tfvars` for configuration changes
* Run `terraform apply` after Git commit

**Do Not:**
* Make manual AWS Console changes
* Skip `terraform plan`
* Commit `terraform.tfvars` with secrets
* Use `terraform destroy` without approval

---

## GitOps Standards

All infrastructure changes require:

1. **Git branch creation** — `git checkout -b fix/<issue>`
2. **Git commit** — Format: `fix: <issue description>`
3. **Terraform apply** — `terraform apply` after merge
4. **Validation testing** — Confirm fix with `curl` or console

**Example workflow:**
```bash
git checkout -b fix/alb-healthcheck-path
# Edit terraform.tfvars
git add infrastructure/environments/dev/terraform.tfvars
git commit -m "fix: corrected ALB health check path"
git push -u origin fix/alb-healthcheck-path
```

---

## Validation Rules

After remediation, AI must validate:

| Check | Command | Expected Result |
|-------|---------|-----------------|
| Target group healthy | AWS Console → Target Groups | Status: healthy |
| ALB accessible | `curl http://<alb-dns>` | HTTP 200 OK |
| Application UI | Browser access | Page loads successfully |

**Validation command example:**
```bash
curl -I http://<alb-dns>
```

Expected result: `HTTP/1.1 200 OK`

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
* Check `terraform.tfstate` for resource IDs when needed

**Do Not:**
* Suggest manual AWS Console changes
* Recommend Docker/containerization for this application
* Skip GitOps workflow for any change
* Omit validation steps from remediation
* Modify state files directly

---

## Demo & Training Objective

This environment is designed for:

* DevOps demonstrations
* AI-assisted troubleshooting
* Terraform remediation demos
* AWS incident analysis
* Infrastructure RCA workflows
* SRE operational simulations

**Key Learning Outcomes:**
* Understanding Terraform state management
* GitOps workflow for infrastructure changes
* RCA methodology for cloud incidents
* Security group troubleshooting
* ALB and target group health checks
