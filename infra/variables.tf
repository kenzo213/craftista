variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "craftista"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "github_owner" {
  type    = string
  default = "kenzo213"
}

variable "github_repo" {
  type    = string
  default = "craftista"
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access EKS public endpoint"
  default     = ["136.62.189.186/32"]  # Your current IP
}
