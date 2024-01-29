output "service-url" {
  value = aws_lb.lb.dns_name
}

output "ecr-url" {
  value = aws_ecr_repository.ecr.repository_url
}
