variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "project-name" {
  type        = string
  default     = "fargate-nextjs-webapp"
}
