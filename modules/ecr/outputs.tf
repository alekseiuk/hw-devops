output "repository_url" {
  description = "URL створеного ECR репозиторію"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN ECR репозиторію"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Назва ECR репозиторію"
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "ID реєстру (AWS Account ID), де створено репозиторій"
  value       = aws_ecr_repository.this.registry_id
}