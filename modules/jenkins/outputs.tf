output "jenkins_namespace" {
  description = "Неймспейс, у якому встановлено Jenkins"
  value       = helm_release.jenkins.namespace
}

output "jenkins_release_name" {
  description = "Назва Helm-релізу Jenkins"
  value       = helm_release.jenkins.name
}