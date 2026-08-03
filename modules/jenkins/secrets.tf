resource "aws_secretsmanager_secret" "jenkins_admin" {
  name                    = "prod/jenkins/admin"
  description             = "Jenkins admin credentials"
  recovery_window_in_days = 0 # Дозволяє миттєво видаляти секрет при terraform destroy
}

resource "random_password" "jenkins_admin" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret_version" "jenkins_admin" {
  secret_id = aws_secretsmanager_secret.jenkins_admin.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.jenkins_admin.result
  })
}

# Створюємо секрет для GitHub
resource "aws_secretsmanager_secret" "github_token" {
  name                    = "prod/jenkins/github"
  description             = "GitHub credentials for Jenkins Pipeline"
  recovery_window_in_days = 0 # Дозволяє миттєво видаляти секрет при terraform destroy
}

# Кладемо логін та токен у секрет
resource "aws_secretsmanager_secret_version" "github_token_version" {
  secret_id = aws_secretsmanager_secret.github_token.id
  secret_string = jsonencode({
    username = var.github_username
    password = var.github_token
  })
}