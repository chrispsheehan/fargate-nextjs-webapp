variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "instance-tenancy" {
  description = "it defines the tenancy of VPC. Whether it's default or dedicated"
  type        = string
  default     = "default"
}
variable "custom-vpc" {
  description = "Fargate vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project-name" {
  type    = string
  default = "fargate-nextjs-webapp"
}

variable "container-image" {
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

variable "container-port" {
  type    = number
  default = 80
}

variable "host_port" {
  type    = number
  default = 80
}
