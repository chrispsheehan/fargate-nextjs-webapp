output "ecr-repo" {
  value = aws_ecr_repository.ecr.repository_url
}