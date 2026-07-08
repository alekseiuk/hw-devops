variable "aws_region" {
  description = "AWS регіон для розгортання інфраструктури"
  type        = string
  default     = "eu-central-1"
}

# --- Змінні для S3 Backend ---
variable "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування"
  type        = string
}

# --- Змінні для VPC ---
variable "vpc_name" {
  description = "Ім'я VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
}

variable "availability_zones" {
  description = "Список зон доступності"
  type        = list(string)
}

# --- Змінні для ECR ---
variable "ecr_repository_name" {
  description = "Назва для ECR репозиторію"
  type        = string
}