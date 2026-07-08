# Отримання інформації про поточний акаунт AWS
data "aws_caller_identity" "current" {}

# Створення самого репозиторію ECR
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  # Автоматичне сканування образів на вразливості при push
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Налаштування політики доступу (ECR Repository Policy)
resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullPush"
        Effect = "Allow"
        # Обмежуємо доступ: лише ресурси поточного AWS-акаунта
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}