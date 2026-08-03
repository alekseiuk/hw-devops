output "monitoring_namespace" {
  description = "Неймспейс, де розгорнуто моніторинг"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_admin_password_command" {
  description = "Команда для отримання автоматично згенерованого пароля Grafana"
  # Стандартна назва секрету для Grafana у цьому чарті: <release_name>-grafana
  value = "kubectl get secret --namespace ${kubernetes_namespace.monitoring.metadata[0].name} prometheus-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode ; echo"
}