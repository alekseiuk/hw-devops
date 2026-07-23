variable "aws_region" {
  description = "AWS регіон для розгортання інфраструктури"
  type        = string
  default     = "eu-central-1"
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

# --- Змінні для ECR ---
variable "ecr_repository_name" {
  description = "Назва для ECR репозиторію"
  type        = string
}

# --- Змінні для EKS ---
variable "eks_instance_type" {
  description = "Тип EC2 інстансу для Worker Nodes"
  type        = string
}

variable "eks_desired_size" {
  description = "Бажана кількість Worker Nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Максимальна кількість Worker Nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Мінімальна кількість Worker Nodes"
  type        = number
}

variable "allowed_api_ips" {
  description = "Список IP-адрес (CIDR), яким дозволено доступ до EKS API"
  type        = list(string)
}