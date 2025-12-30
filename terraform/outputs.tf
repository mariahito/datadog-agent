output "dev_ip" {
  description = "Public IP of Dev Server"
  value       = aws_instance.dev_server.public_ip
}

output "test_ip" {
  description = "Public IP of Test Server"
  value       = aws_instance.test_server.public_ip
}

output "prod_ip" {
  description = "Public IP of Prod Server"
  value       = aws_instance.prod_server.public_ip
}

output "private_key" {
  description = "SSH Private Key for Ansible access"
  value       = tls_private_key.pk.private_key_pem
  sensitive   = true
}
