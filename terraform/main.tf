terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_pet" "name" {}

resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.deploy_key.private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}

resource "aws_key_pair" "deploy" {
  key_name   = "foodsite-${random_pet.name.id}"
  public_key = tls_private_key.deploy_key.public_key_openssh
}

resource "aws_security_group" "web_sg" {
  name        = "foodsite-sg-${random_pet.name.id}"
  description = "Allow HTTP and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deploy.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "food-ordering-site-${random_pet.name.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io docker-compose",
      "sudo systemctl enable --now docker",
      "sudo docker run -d --name nginx-test -p 80:80 nginx:alpine || true"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = tls_private_key.deploy_key.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "local_file" "ansible_inventory" {
  content  = "[web]\n${aws_instance.web.public_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=\"${path.module}/id_rsa\"\n"
  filename = "${path.module}/../ansible/inventory.ini"
}

output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "ansible_inventory" {
  value = local_file.ansible_inventory.filename
}
