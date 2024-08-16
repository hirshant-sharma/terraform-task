output "VPC-ID" {
  description = "VPC ID"
  value       = aws_vpc.dev.id
}

output "EC2-PublicIP" {
  description = "Public id of nginx server"
  value       = aws_instance.nginxserver.public_ip
}

