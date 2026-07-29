resource "aws_secretsmanager_secret" "django_secrets" {
  name        = "prod/django/secrets"
  description = "Секрети для Django застосунку"
}

resource "aws_secretsmanager_secret" "jenkins_admin" {
  name        = "prod/jenkins/admin"
  description = "Jenkins admin credentials"
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