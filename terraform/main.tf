# --- Security Group ---
resource "aws_security_group" "datadog_demo_sg" {
  name        = "datadog-demo-sg"
  description = "Allow SSH, Web, and K8s API traffic"

  # SSH (Ansible Access)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Web Traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MicroK8s API (Optional, for debugging)
  ingress {
    from_port   = 16443
    to_port     = 16443
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

# --- SSH Key Generation ---
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${path.module}/ansible_key.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

# --- EC2 Instances ---
resource "aws_instance" "dev_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.datadog_demo_sg.name]

  tags = {
    Name = "Datadog-Demo-Dev"
    Env  = "dev"
  }
}

resource "aws_instance" "test_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.datadog_demo_sg.name]

  tags = {
    Name = "Datadog-Demo-Test"
    Env  = "test"
  }
}

resource "aws_instance" "prod_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.datadog_demo_sg.name]

  tags = {
    Name = "Datadog-Demo-Prod"
    Env  = "prod"
  }
}
