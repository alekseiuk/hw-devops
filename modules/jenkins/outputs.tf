output "jenkins_namespace" {
  description = "Неймспейс, у якому встановлено Jenkins"
  value       = helm_release.jenkins.namespace
}

output "jenkins_release_name" {
  description = "Назва Helm-релізу Jenkins"
  value       = helm_release.jenkins.name
}

output "jenkins_admin_username" {
  description = "Jenkins admin username"
  value       = "admin"
}

output "jenkins_admin_password" {
  description = "Команда для отримання Jenkins admin-пароля з AWS Secrets Manager"
  value       = "aws secretsmanager get-secret-value --secret-id prod/jenkins/admin --query 'SecretString' --output text | jq -r '.password'"
}