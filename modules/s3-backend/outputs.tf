output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN S3-бакета (необхідно для IAM політик)"
  value       = aws_s3_bucket.terraform_state.arn
}
