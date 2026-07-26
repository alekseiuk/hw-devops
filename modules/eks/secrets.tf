resource "aws_secretsmanager_secret" "django_secrets" {
  name        = "prod/django/secrets" # Назва сейфа в AWS
  description = "Секрети для Django застосунку"
}
