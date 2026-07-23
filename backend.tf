terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-in-0574" # Назва S3-бакета
    key            = "dev-env/terraform.tfstate"     # Шлях до файлу стейту
    region         = "eu-central-1"                   # Регіон AWS
    use_lockfile   = true                             # Вмикаємо нативне блокування S3 замість Dynamo
    encrypt        = true                             # Шифрування файлу стейту
  }
}

