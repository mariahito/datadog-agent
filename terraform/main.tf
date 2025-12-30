# Security Group: Allow SSH (22) and standard Web (80/443)
resource "aws_security_group" "demo_sg" {
  name        = "datadog-demo-sg"
  description = "Allow SSH inbound"

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

# Generate SSH Key for Ansible to use
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "datadog-demo-key"
  public_key = tls_private_key.demo_key.public_key_openssh
}

# Save the private key locally so Ansible can read it
resource "local_file" "private_key" {
  content         = tls_private_key.demo_key.private_key_pem
  filename        = "${path.module}/ansible_key.pem"
  file_permission = "0400"
}

# Create the 3 Instances (Dev, Test, Prod)
resource "aws_instance" "datadog_node" {
  count           = length(var.environment_stages)
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.demo_sg.name]

  tags = {
    Name = "Datadog-Demo-${var.environment_stages[count.index]}"
    Env  = var.environment_stages[count.index]
  }
}
