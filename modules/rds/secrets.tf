# Створюємо секрет для Django та бази даних
resource "aws_secretsmanager_secret" "django_secrets" {
  name                    = "prod/django/secrets"
  description             = "Секрети для Django застосунку та доступи до БД"
  recovery_window_in_days = 0 # Дозволяє миттєво видаляти секрет при terraform destroy
}

# Генеруємо безпечний пароль для бази даних
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Генеруємо SECRET_KEY для Django
resource "random_password" "django_secret_key" {
  length           = 50
  special          = true
  override_special = "!@#$%^&*(-_=+)"
}

# Зберігаємо всі дані у Secret Version
resource "aws_secretsmanager_secret_version" "django_secrets_version" {
  secret_id = aws_secretsmanager_secret.django_secrets.id
  secret_string = jsonencode({
    # Динамічно отримуємо адресу бази даних (Aurora або звичайний RDS)
    POSTGRES_HOST = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].address
    POSTGRES_PORT = var.use_aurora ? tostring(aws_rds_cluster.aurora[0].port) : tostring(aws_db_instance.standard[0].port)

    # Беремо назву БД та користувача напряму зі змінних Terraform
    POSTGRES_DB       = var.db_name
    POSTGRES_USER     = var.username
    POSTGRES_PASSWORD = random_password.db_password.result
    SECRET_KEY        = random_password.django_secret_key.result
  })
}