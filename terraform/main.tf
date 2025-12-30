terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change if needed
}

# Security Group to allow SSH (for Ansible) and verify HTTP (optional)
resource "aws_security_group" "demo_sg" {
  name        = "datadog-demo-sg"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this IP!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a private key for SSH access (For demo purposes only)
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "datadog-demo-key"
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.demo_key.private_key_pem
  filename = "${path.module}/ansible_key.pem"
  file_permission = "0400"
}

# Define the 3 Environments
variable "envs" {
  type    = list(string)
  default = ["Dev", "Test", "Prod"]
}

resource "aws_instance" "datadog_node" {
  count         = 3
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.demo_sg.name]

  tags = {
    Name = "Datadog-Demo-${var.envs[count.index]}"
    Env  = var.envs[count.index]
  }
}

# Output IPs for Ansible Inventory
output "dev_ip" { value = aws_instance.datadog_node[0].public_ip }
output "test_ip" { value = aws_instance.datadog_node[1].public_ip }
output "prod_ip" { value = aws_instance.datadog_node[2].public_ip }
