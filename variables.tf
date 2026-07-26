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
variable "eks_cluster_name" {
  description = "Назва кластера EKS"
  type        = string
}

variable "eks_cluster_version" {
  description = "Версія Kubernetes для кластера EKS"
  type        = string
  default     = "1.36"
}

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

# --- Змінні для Argo CD ---
variable "argocd_app_repo_url" {
  description = "URL Git-репозиторію з Helm-чартом застосунку"
  type        = string
}

variable "argocd_app_target_revision" {
  description = "Гілка або тег у репозиторії для Argo CD"
  type        = string
  default     = "main"
}