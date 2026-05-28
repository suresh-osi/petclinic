resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_1" {
vpc_id                  = aws_vpc.main.id
cidr_block              = "10.0.1.0/24"
availability_zone       = "ap-south-1a"
map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
vpc_id                  = aws_vpc.main.id
cidr_block              = "10.0.2.0/24"
availability_zone       = "ap-south-1b"
map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet" {
route_table_id         = aws_route_table.rt.id
destination_cidr_block = "0.0.0.0/0"
gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "a1" {
subnet_id      = aws_subnet.public_1.id
route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
subnet_id      = aws_subnet.public_2.id
route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "alb_sg" {
vpc_id = aws_vpc.main.id

ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_security_group" "ec2_sg" {
vpc_id = aws_vpc.main.id

ingress {
from_port       = 8080
to_port         = 8080
protocol        = "tcp"
security_groups = [aws_security_group.alb_sg.id]
}

ingress {
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}

data "aws_ami" "ubuntu" {
most_recent = true

owners = ["099720109477"] # Canonical

filter {
name   = "name"
values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

filter {
name   = "virtualization-type"
values = ["hvm"]
}
}

resource "aws_instance" "petclinic" {
ami                    = data.aws_ami.ubuntu.id
instance_type          = var.instance_type
subnet_id              = aws_subnet.public_1.id
vpc_security_group_ids = [aws_security_group.ec2_sg.id]

user_data_replace_on_change = true
user_data = <<-EOF
#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

echo "=== Starting PetClinic setup ==="

apt-get update -y
apt-get install -y git curl openjdk-17-jdk

java -version

cd /opt
git clone https://github.com/suresh-osi/petclinic.git
cd /opt/petclinic

chmod +x mvnw
export HOME=/root

echo "=== Building PetClinic ==="
./mvnw package -DskipTests

echo "=== Starting PetClinic ==="
nohup java -jar /opt/petclinic/target/*.jar --server.port=8080 > /opt/petclinic/app.log 2>&1 &

echo "PetClinic started with PID $!"
EOF

tags = {
Name = "petclinic-server"
}
}

resource "aws_lb" "alb" {
name               = "petclinic-alb"
internal           = false
load_balancer_type = "application"

security_groups = [aws_security_group.alb_sg.id]

subnets = [
aws_subnet.public_1.id,
aws_subnet.public_2.id
]
}

resource "aws_lb_target_group" "tg" {
name     = "petclinic-tg"
port     = 8080
protocol = "HTTP"
vpc_id   = aws_vpc.main.id

health_check {
path                = "/"

}
}

resource "aws_lb_target_group_attachment" "attach" {
target_group_arn = aws_lb_target_group.tg.arn
target_id        = aws_instance.petclinic.id
port             = 8080
}

resource "aws_lb_listener" "listener" {
load_balancer_arn = aws_lb.alb.arn

port     = 80
protocol = "HTTP"

default_action {
type             = "forward"
target_group_arn = aws_lb_target_group.tg.arn
}
}
