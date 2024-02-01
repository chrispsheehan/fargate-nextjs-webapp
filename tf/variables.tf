variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "desired_count" {
  description = "number of containers the load balancer will point to"
  default     = 2
}

variable "max_az" {
  description = "limit the amount of azs"
  default     = 3
}

variable "project_name" {
  type = string
  default = "fargate-nextjs-webapp"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "load_balancer_port" {
  type    = number
  default = 80
}
