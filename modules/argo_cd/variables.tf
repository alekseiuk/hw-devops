variable "namespace" {
  description = "Неймспейс для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія офіційного чарту Argo CD"
  type        = string
  default     = "6.7.11"
}

variable "app_repo_url" {
  description = "URL Git-репозиторію з вашим Django Helm-чартом"
  type        = string
}

variable "app_target_revision" {
  description = "Гілка або тег у репозиторії"
  type        = string
  default     = "main"
}