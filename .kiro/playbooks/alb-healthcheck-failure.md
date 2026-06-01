# ALB Health Check Failure Playbook

| Field | Value |
|-------|-------|
| **Playbook Name** | ALB Health Check Failure |
| **Severity Level** | P2 — Service degraded, partial outage |
| **Runbook Owner** | DevOps Team |
| **Last Updated** | 2026-06-01 |
| **Related Services** | AWS ALB, EC2, Security Groups |
| **Auto-Remediation Available** | No — requires human review |

---

## Executive Summary

ALB target group reports unhealthy targets, resulting in HTTP 503 responses. The Spring PetClinic application is unreachable via the load balancer.

---

## Symptoms

* HTTP 503 from ALB DNS
* Target group shows targets as unhealthy in AWS Console
* Application UI not loading
* CloudWatch `UnHealthyHostCount` metric > 0

---

## Architecture Reference

| Component | Value | Terraform Reference |
|-----------|-------|---------------------|
| ALB Listener | HTTP port 80 | `aws_lb_listener.listener` |
| EC2 App Port | 8080 | `var.app_port` |
| Health Check Path | `/` | `var.health_check_path` |
| ALB Name | `petclinic-alb` | `aws_lb.alb` |
| Target Group | `petclinic-tg` | `aws_lb_target_group.tg` |
| EC2 SG Inbound | Port 8080 from ALB SG | `aws_security_group.ec2_sg` |

---

## Investigation Steps

### 1. Check ALB Target Group Health
- Go to EC2 → Target Groups → `petclinic-tg`
- Verify target health status and failure reason
- Check `Last status reason` for specific error (e.g., "Request timeout", "Health checks failed")

### 2. Validate Health Check Path
- In `infrastructure/environments/dev/alb.tf`, confirm `health_check { path = var.health_check_path }`
- In `infrastructure/environments/dev/variables.tf`, confirm `health_check_path` default is `/`
- Spring PetClinic serves the root path `/` — this must match

### 3. Verify Application Port
- ALB listener forwards to `var.app_port` (default: `8080`)
- EC2 security group (`ec2_sg`) must allow inbound on port `8080` from `alb_sg`
- Check `infrastructure/environments/dev/security_groups.tf` for the ingress rule

### 4. Check EC2 Application Availability
- SSH into EC2 instance
- Run: `curl http://localhost:8080/`
- Expected: HTTP 200 response

### 5. Check EC2 App Logs
- `sudo journalctl -u petclinic --no-pager -n 100`
- Look for startup errors or port binding failures

---

## Common Root Causes

### Scenario 1 — Wrong Health Check Path
- **Symptom**: HTTP 503, targets unhealthy
- **Cause**: `health_check_path` variable set to a non-existent endpoint
- **Fix**: Update `infrastructure/environments/dev/terraform.tfvars` → set `health_check_path = "/"`

### Scenario 2 — Wrong Target Port
- **Symptom**: Connection timeout on health check
- **Cause**: `app_port` variable not matching actual application port
- **Fix**: Update `infrastructure/environments/dev/terraform.tfvars` → set `app_port = 8080`

### Scenario 3 — Security Group Misconfiguration
- **Symptom**: Connection refused, health check fails
- **Cause**: EC2 security group not allowing inbound from ALB security group on port 8080
- **Fix**: Verify `infrastructure/environments/dev/security_groups.tf` — `ec2_sg` ingress must reference `aws_security_group.alb_sg.id`

---

## Remediation

### Step 1 — Identify the Misconfiguration

```bash
# Review current variable values
cat infrastructure/environments/dev/terraform.tfvars
```

### Step 2 — Apply the Fix

Edit `infrastructure/environments/dev/terraform.tfvars`:

```hcl
health_check_path = "/"
app_port          = 8080
```

### Step 3 — Plan and Apply

```bash
cd infrastructure/environments/dev
terraform plan
terraform apply
```

---

## Validation

After applying the fix, validate recovery:

```bash
# Get ALB DNS from Terraform output
terraform output alb_dns_name

# Test HTTP response
curl -I http://<alb-dns-name>
```

Expected result: `HTTP/1.1 200 OK`

Also verify in AWS Console:
- Target group → Targets → Status: **healthy**

---

## Escalation Path

| Severity | Action | Contact |
|----------|--------|---------|
| P2 (Service Degraded) | Notify DevOps Team | #devops-alerts channel |
| P1 (Complete Outage) | Escalate to Engineering Lead | PagerDuty |

---

## Timeline Tracking

| Event | Timestamp | Action |
|-------|-----------|--------|
| Incident Detected | | |
| Investigation Started | | |
| Root Cause Identified | | |
| Remediation Started | | |
| Service Restored | | |
| Post-Incident Review | | Schedule within 72 hours |

---

## Post-Incident Review (PIR)

Trigger a PIR when:
- Incident duration > 30 minutes
- Multiple root causes identified
- Remediation required multiple team members

PIR output should include:
- Timeline of events
- Root cause analysis
- Impact assessment
- Action items for prevention

---

## GitOps Requirements

All remediation changes must follow the GitOps workflow:

```bash
git checkout -b fix/alb-healthcheck-path
git add infrastructure/environments/dev/terraform.tfvars
git commit -m "fix: corrected ALB health check path"
git push -u origin fix/alb-healthcheck-path
```

---

## Preventive Recommendations

* Pin `health_check_path` explicitly in `terraform.tfvars` — do not rely on variable defaults
* Add ALB health check monitoring via CloudWatch alarm on `UnHealthyHostCount`
* Include a post-deploy validation step in `scripts/deploy.sh` that curls the ALB endpoint
* Add Terraform validation in CI/CD pipeline to catch misconfigurations before apply

---

## Related Playbooks

* [EC2 Application Failure](../playbooks/ec2-application-failure.md)
* [Security Group Misconfiguration](../playbooks/security-group-misconfiguration.md)
* [VPC Routing Issues](../playbooks/vpc-routing-issues.md)
