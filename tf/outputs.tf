output "ecr-repo-url" {
  value = data.aws_ecr_repository.nginx.repository_url
}

output "service-url" {
  value = aws_lb.example.dns_name
}
