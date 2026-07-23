variable "aws_region" {
  description = "AWS регіон для розгортання S3 бекенду"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "Назва S3-бакета для Terraform state"
  type        = string
}