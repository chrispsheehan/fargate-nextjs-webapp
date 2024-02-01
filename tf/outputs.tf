output "service-url" {
  value = "${aws_lb.lb.dns_name}:${var.load_balancer_port}"
}
