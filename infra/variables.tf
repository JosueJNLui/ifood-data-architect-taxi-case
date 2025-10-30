################################################################################
# AWS - Amazon Web Services
################################################################################
variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "dev"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

################################################################################
# Projects Info
################################################################################
variable "company" {
  description = "Company Name"
  type        = string
}

variable "project" {
  description = "Project Name"
  type        = string
}

################################################################################
# S3 Buckets
################################################################################
variable "s3_buckets" {
  description = "The S3 Buckets to create."
  type        = any
  default     = null
}

################################################################################
# Route53 - Zone
################################################################################
variable "zones" {
  description = "Map of Route53 zone parameters"
  type        = any
  default     = {}
}

################################################################################
# Cloudfront
################################################################################
variable "cloudfront_s3_buckets" {
  description = "The Cloudfront to create to serve data via S3 Buckets"
  type        = any
  default     = null
}

variable "domain_names" {
  description = "Lista de nomes de domínio (ex: nglui.com) para obter a Hosted Zone do Route 53."
  type        = list(string)
  default     = ["nglui.com"] # Exemplo
}