variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for static site"
  type        = string
}

