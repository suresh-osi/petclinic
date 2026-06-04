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

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "petclinic-alb"
}

variable "app_port" {
  description = "Application server port"
  type        = number
  default     = 8080
}

variable "alb_listener_port" {
  description = "ALB listener port (external-facing)"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/"
}

variable "ssh_cidr" {
  description = "CIDR for SSH access to EC2"
  type        = string
  default     = "0.0.0.0/0"
}
