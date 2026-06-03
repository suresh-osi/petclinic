variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "ap-south-1a"
}

variable "availability_zone_2" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "ap-south-1b"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "petclinic-alb"
}

variable "target_group_name" {
  description = "Name of the ALB target group"
  type        = string
  default     = "petclinic-tg"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "alb_listener_port" {
  description = "Port the ALB listener listens on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

variable "ec2_name_tag" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "petclinic-server"
}

variable "ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ubuntu_ami_owner" {
  description = "AWS account ID of the Ubuntu AMI owner (Canonical)"
  type        = string
  default     = "099720109477"
}

variable "ubuntu_ami_filter" {
  description = "Name filter for the Ubuntu AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "internet_route_cidr" {
  description = "Destination CIDR block for the default internet route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "alb_security_group_name" {
  description = "Name tag for the ALB security group"
  type        = string
  default     = "petclinic-alb-sg"
}

variable "ec2_security_group_name" {
  description = "Name tag for the EC2 security group"
  type        = string
  default     = "petclinic-ec2-sg"
}

variable "alb_ingress_cidr" {
  description = "CIDR block allowed for ALB ingress (HTTP traffic)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_egress_cidr" {
  description = "CIDR block allowed for ALB egress"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ec2_egress_cidr" {
  description = "CIDR block allowed for EC2 egress"
  type        = string
  default     = "0.0.0.0/0"
}

variable "newrelic_external_id" {
  description = "External ID for NewRelic IAM role trust policy"
  type        = string
  default     = ""
}

variable "newrelic_license_key" {
  description = "NewRelic Ingest License Key for log forwarding"
  type        = string
  sensitive   = true
  default     = ""
}

variable "newrelic_account_id" {
  description = "NewRelic Account ID"
  type        = string
  default     = "8131360"
}
