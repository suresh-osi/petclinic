# ALB Health Check Failure Playbook

Symptoms:

* HTTP 503
* ALB unhealthy targets

Investigation:

1. Check ALB target group
2. Validate health check path
3. Verify application port
4. Check EC2 app logs

Common Root Cause:
Incorrect health check path.

Remediation:
Update Terraform health_check path and reapply infrastructure.
