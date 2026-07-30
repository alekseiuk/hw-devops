output "db_endpoint" {
  description = "Connection endpoint бази даних (для запису/читання)"
  # Якщо use_aurora = true, беремо endpoint з кластера, інакше — з інстансу RDS
  value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].address
}

output "aurora_reader_endpoint" {
  description = "Read-only endpoint для кластера Aurora (балансує навантаження між репліками)"
  # Якщо це не Aurora, повертаємо null, оскільки у звичайного RDS тут немає такого поняття
  value = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "db_port" {
  description = "Порт для підключення до бази даних"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.standard[0].port
}

output "db_name" {
  description = "Назва бази даних"
  value       = var.db_name
}

output "db_username" {
  description = "Ім'я користувача-адміністратора"
  value       = var.username
}

output "db_security_group_id" {
  description = "ID створеної Security Group для бази даних (може знадобитись для інших ресурсів)"
  value       = aws_security_group.rds.id
}