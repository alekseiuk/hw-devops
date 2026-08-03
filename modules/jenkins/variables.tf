variable "cluster_name" {
  description = "Назва кластера EKS"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера кластера"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера кластера"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN ECR репозиторію"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}