instance_type        = "t3.small"
aws_region           = "ap-south-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"
availability_zone_1  = "ap-south-1a"
availability_zone_2  = "ap-south-1b"
alb_name             = "petclinic-alb"
target_group_name    = "petclinic-tg"
app_port             = 8080
alb_listener_port    = 80
health_check_path    = "/"
ec2_name_tag         = "petclinic-server"
ssh_cidr             = "0.0.0.0/0"
ubuntu_ami_owner     = "099720109477"
ubuntu_ami_filter    = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
newrelic_external_id = ""
newrelic_account_id  = "8131360"

# REQUIRED: Set your NewRelic Ingest License Key
# Get it from: https://one.newrelic.com → (your account) → API Keys → INGEST - LICENSE
# Set via environment variable: export TF_VAR_newrelic_license_key="NRAK-..."
newrelic_license_key = ""
