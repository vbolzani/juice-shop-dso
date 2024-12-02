terraform {
  backend "s3" {
    bucket = "vbolzani-terraform-state-2"
    key    = "tfstate/state"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

variable "EC2_PUBLIC_KEY" {
  type = string
}

resource "aws_key_pair" "github-deployer" {
  key_name   = "github-deploy"
  public_key = var.EC2_PUBLIC_KEY
}

data "aws_vpc" "default" {
 default = true
}

resource "aws_security_group" "juiceshop-security-group" {
  name        = "juiceshop-security-group"
  description = "Allow 8080 and 22"

  ingress {
    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP juiceshop ingress"
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "test1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name        = aws_key_pair.github-deployer.key_name
  vpc_security_group_ids = [aws_security_group.juiceshop-security-group.id]


  user_data = <<EOF
#!/bin/bash

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu
EOF


}

output "deployed_public_ip" {
    value = aws_instance.test1.public_ip
}