# Створюємо неймспейс
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Встановлюємо kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
resource "helm_release" "kube_prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
}

# Встановлюємо Metrics Server (Критично важливо для авто-масштабування Django через HPA)
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}