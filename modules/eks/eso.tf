resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }

  depends_on = [aws_eks_node_group.general]
}

# Встановлюємо External Secrets Operator через Helm
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.11" # Фіксуємо стабільну версію
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  # Обов'язково вказуємо створити CRD (Custom Resource Definitions),
  # щоб Kubernetes зрозумів нові ресурси, такі як ExternalSecret
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "eso_resources" {
  name      = "eso-resources"
  chart     = "${path.module}/charts/eso-resources"
  namespace = kubernetes_namespace.external_secrets.metadata[0].name

  depends_on = [helm_release.external_secrets]
}