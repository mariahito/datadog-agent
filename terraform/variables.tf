variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Ubuntu 22.04 LTS AMI (us-east-1)
variable "ami_id" {
  description = "AMI ID for Ubuntu"
  type        = string
  default     = "ami-0c7217cdde317cfec" 
}

# The 3 environments required by the prompt 
variable "environment_stages" {
  description = "List of environments to deploy"
  type        = list(string)
  default     = ["Dev", "Test", "Prod"]
}
