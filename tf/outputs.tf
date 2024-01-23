output "ecr-repo-url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "service-url" {
  value = aws_lb.example.dns_name
}
