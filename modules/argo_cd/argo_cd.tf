resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# 1. Встановлення офіційного Argo CD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]
}

# 2. Встановлення кастомного чарту з нашими Applications та Repositories
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts" # Шлях до локального чарту
  namespace = kubernetes_namespace.argocd.metadata[0].name

  # Цей реліз має ставитися тільки після того, як Argo CD встановить свої CRD
  depends_on = [helm_release.argocd]

  # Передаємо змінні Terraform у наш локальний Helm-чарт
  set {
    name  = "repository.url"
    value = var.app_repo_url
  }

  set {
    name  = "application.targetRevision"
    value = var.app_target_revision
  }
}