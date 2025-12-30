output "dev_ip" {
  description = "Public IP of the Dev environment"
  value       = aws_instance.datadog_node[0].public_ip
}

output "test_ip" {
  description = "Public IP of the Test environment"
  value       = aws_instance.datadog_node[1].public_ip
}

output "prod_ip" {
  description = "Public IP of the Prod environment"
  value       = aws_instance.datadog_node[2].public_ip
}
