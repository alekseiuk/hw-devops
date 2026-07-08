# ==========================================
# S3 BACKEND OUTPUTS
# ==========================================
output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

# ==========================================
# VPC OUTPUTS
# ==========================================
output "vpc_id" {
  description = "ID основної VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR блок основної VPC"
  value       = module.vpc.vpc_cidr_block
}

output "nat_gateway_ip" {
  description = "Зовнішня IP-адреса інфраструктури (через NAT)"
  value       = module.vpc.nat_gateway_public_ip
}

# ==========================================
# ECR OUTPUTS
# ==========================================
output "ecr_repository_url" {
  description = "URL ECR-репозиторію"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR-репозиторію"
  value       = module.ecr.repository_arn
}