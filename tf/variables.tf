variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "vpc_cidr_block" {
  description = "Fargate vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  type    = string
  default = "fargate-nextjs-webapp"
}

variable "container_image" {
  type    = string
  default = "nginx:latest"
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
  default = 80
}

variable "host_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  default = 2
}
