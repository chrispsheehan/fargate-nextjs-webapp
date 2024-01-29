variable "region" {
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  type    = string
  default = "fargate-mvp"
}

variable "desired_count" {
  description = "number of containers the load balancer will point to"
  default = 2
}

variable "max_az" {
  description = "limit the amount of azs"
  default = 3
}
