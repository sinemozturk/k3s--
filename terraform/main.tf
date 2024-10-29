terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate an SSH key pair
resource "tls_private_key" "k3s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the public key to AWS as an EC2 key pair
resource "aws_key_pair" "k3s_key" {
  key_name   = "k3s-keypair"
  public_key = tls_private_key.k3s_key.public_key_openssh
}

# Create a Security Group for K3s
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-cluster-sg"
  description = "Security group for K3s cluster"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Master Node
resource "aws_instance" "k3s_master" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k3s_key.key_name
  security_groups = [aws_security_group.k3s_sg.name]
  tags = {
    Name = "k3s-master-node"
  }
}

# Create Worker Nodes
resource "aws_instance" "k3s_workers" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k3s_key.key_name
  security_groups = [aws_security_group.k3s_sg.name]
  tags = {
    Name = "k3s-worker-node-${count.index + 1}"
  }
}
