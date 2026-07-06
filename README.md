# Terraform AWS Infrastructure

## Опис

Цей проєкт автоматизує створення базової інфраструктури в AWS за допомогою Terraform.

Створюються такі ресурси:
- S3 Bucket для зберігання Terraform state.
- DynamoDB Table для блокування Terraform state.
- VPC з мережею.
- Amazon ECR Repository для Docker-образів.

---

## Структура проєкту

```text
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування S3 backend і DynamoDB для Terraform state
├── outputs.tf               # Загальне виведення результатів
│
├── modules/                 # Каталог модулів
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3 Bucket
│   │   ├── dynamodb.tf      # Створення DynamoDB Table
│   │   ├── variables.tf     # Вхідні змінні
│   │   └── outputs.tf       # Виведення інформації про ресурси
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж та Internet Gateway
│   │   ├── routes.tf        # Налаштування таблиць маршрутизації
│   │   ├── variables.tf     # Вхідні змінні
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   └── ecr/                 # Модуль для Amazon ECR
│       ├── ecr.tf           # Створення ECR-репозиторію
│       ├── variables.tf     # Вхідні змінні
│       └── outputs.tf       # Виведення URL репозиторію
│
└── README.md                # Документація проєкту
```

---

## Команди для запуску

Ініціалізація Terraform:

```bash
terraform init
```

Перегляд плану:

```bash
terraform plan
```

Створення інфраструктури:

```bash
terraform apply
```

Видалення інфраструктури:

```bash
terraform destroy
```

---

## Опис модулів

### s3-backend

Створює:
- S3 Bucket для зберігання Terraform state;
- DynamoDB Table для блокування Terraform state.

### vpc

Створює:
- VPC;
- підмережі (якщо передбачено конфігурацією);
- мережеву інфраструктуру.

### ecr

Створює:
- Amazon ECR Repository;
- автоматичне сканування Docker-образів (`scan_on_push`);
- політику доступу до репозиторію;
- виводить URL репозиторію через `outputs.tf`.

---

## Outputs

Після виконання `terraform apply` будуть доступні:

- `s3_bucket_name`
- `dynamodb_table_name`
- `ecr_repository_url`