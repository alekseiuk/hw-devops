output "s3_bucket_name" {
  description = "Назва S3-бакета для збереження стейту"
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN створеного S3-бакета"
  value       = module.s3_backend.s3_bucket_arn
}