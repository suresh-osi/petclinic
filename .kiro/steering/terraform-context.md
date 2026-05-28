# Terraform Infrastructure Context

## Platform Overview

This repository manages AWS infrastructure using Terraform.

Infrastructure components include:

* VPC
* Public Subnets
* Route Tables
* Internet Gateway
* Security Groups
* EC2 Instances
* Application Load Balancer
* Target Groups
* Listener Rules

Application deployed:

* Spring PetClinic
* Java 17
* Spring Boot
* Running directly on EC2
* No Docker containers

---

# Terraform Standards

## Infrastructure Rules

* All AWS resources must be created through Terraform
* Manual AWS Console changes are not allowed
* Infrastructure changes must be idempotent
* Resources must support automated remediation

---

# Networking Standards

## ALB Rules

* ALB must expose HTTP port 80
* ALB forwards traffic to EC2 port 8080
* Target groups must use health checks
* Health checks must validate actual application endpoints

---

# Security Group Standards

## ALB Security Group

Allowed:

* Inbound HTTP 80 from 0.0.0.0/0

Denied:

* Direct SSH access

---

## EC2 Security Group

Allowed:

* Port 8080 only from ALB Security Group
* SSH only when required for troubleshooting

---

# Application Standards

Application:

* Spring PetClinic
* Runs on port 8080
* Built using Maven
* Started through EC2 userdata

Expected health endpoint:

* /

---

# Incident Investigation Rules

When application is unavailable:

AI should validate:

1. ALB listener configuration
2. Target group health
3. Health check path
4. EC2 application availability
5. Security group rules
6. Route table configuration
7. Terraform resource dependencies

---

# Common Failure Scenarios

## Scenario 1 — Wrong Health Check Path

Symptoms:

* HTTP 503
* Targets unhealthy

Root Cause:

* Health check endpoint mismatch

Remediation:

* Update target group health_check path

---

## Scenario 2 — Wrong Target Port

Symptoms:

* Connection timeout

Root Cause:

* ALB forwards to incorrect port

Expected:

* EC2 application runs on 8080

---

## Scenario 3 — Security Group Misconfiguration

Symptoms:

* Connection refused

Root Cause:

* ALB unable to reach EC2

Remediation:

* Validate ingress rules

---

# RCA Expectations

AI must generate:

* Incident Summary
* Root Cause
* Impact Analysis
* Terraform Fix
* Validation Steps
* Preventive Recommendation

---

# Terraform Remediation Rules

When fixing infrastructure:

AI should:

* Modify Terraform only
* Avoid manual AWS changes
* Preserve resource integrity
* Avoid destructive recreation where possible

---

# GitOps Standards

All infrastructure changes require:

1. Git branch creation
2. Git commit
3. Terraform apply
4. Validation testing

Commit message format:

fix: <issue>

Example:

fix: corrected ALB health check path

---

# Validation Rules

After remediation AI should validate:

* Target group healthy
* ALB accessible
* HTTP 200 response
* Application UI loads successfully

Validation command example:

curl http://<alb-dns>

Expected result:
HTTP 200 OK

---

# AI Operational Behavior

Kiro AI responsibilities:

* Analyze Terraform code
* Detect infrastructure drift
* Investigate outages
* Generate RCA
* Suggest Terraform remediation
* Validate infrastructure recovery
* Recommend preventive improvements

---

# Demo Objective

This environment is intentionally designed for:

* DevOps demonstrations
* AI-assisted troubleshooting
* Terraform remediation demos
* AWS incident analysis
* Infrastructure RCA workflows
* SRE operational simulations
