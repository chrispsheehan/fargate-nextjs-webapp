output "service-url" {
  value = aws_lb.lb.dns_name
}