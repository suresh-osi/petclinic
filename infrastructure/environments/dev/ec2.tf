data "aws_ami" "ubuntu" {
  most_recent = true

  owners = [var.ubuntu_ami_owner]

  filter {
    name   = "name"
    values = [var.ubuntu_ami_filter]
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
  user_data                   = file("${path.module}/userdata.sh")

  tags = {
    Name = var.ec2_name_tag
  }
}
