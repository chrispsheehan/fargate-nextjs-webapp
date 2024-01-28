variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "project_name" {
  type    = string
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
  default = 80
}

variable "host_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  default = 2
}

variable "max_az" {
  default = 3
}
