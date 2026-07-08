output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN S3-бакета (необхідно для IAM політик)"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN таблиці DynamoDB (необхідно для IAM політик)"
  value       = aws_dynamodb_table.terraform_locks.arn
}