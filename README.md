# 🚀 AWS EKS & Django App Deployment (GitOps with Jenkins & ArgoCD)

Цей проєкт розгортає хмарну інфраструктуру на AWS за допомогою Terraform та використовує підхід GitOps для автоматичного CI/CD конвеєра за допомогою Jenkins та ArgoCD.


## 🏗 Архітектура проєкту

* **Інфраструктура (Terraform):** VPC, EKS, ECR, RDS (PostgreSQL / Aurora).
* **CI/CD (GitOps):** 
  * **Jenkins** (збірка образу без Docker-демона за допомогою Kaniko, пуш в ECR та оновлення тегу в Git).
  * **ArgoCD** (відстежує зміни в Git та автоматично розгортає нові версії в EKS).
* **Секрети:** AWS Secrets Manager + External Secrets Operator (ESO) для автоматичної та безпечної передачі паролів, згенерованих Terraform, у поди кластера.
* **Застосунок:** Django (контейнеризований) з Helm-чартом, автоматичними міграціями БД, HPA (автомасштабування) та Liveness/Readiness пробами.


## ⚙️ Підготовка до запуску

Перед розгортанням переконайтеся, що ви оновили конфігурацію під своє середовище:

1. **Файл `terraform.tfvars`:** 
   Створіть цей файл на основі `terraform.tfvars.example`. Вкажіть посилання на **свій** Git-репозиторій у змінній `argocd_app_repo_url`.
2. **Файл `Jenkinsfile`:**
   Оновіть змінні `AWS_ACCOUNT_ID` (ваш ID акаунта AWS) та `GIT_REPO_URL` (посилання на ваш репозиторій).
3. **Helm-чарт:**
   У файлі `charts/django-app/values.yaml` замініть AWS Account ID у блоці `image.repository` на власний.


## 🗄 Налаштування Бази Даних (Модуль RDS)

Цей проєкт включає гнучкий модуль для розгортання баз даних AWS RDS. Він підтримує як **Standard RDS** (PostgreSQL/MySQL), так і **Amazon Aurora** (PostgreSQL-compatible).

### Приклад використання модуля

Усі необхідні налаштування бази даних передаються через модуль `rds` у головному файлі `main.tf`. Пароль генерується автоматично всередині модуля та зберігається в AWS Secrets Manager.

```hcl
module "rds" {
  source = "./modules/rds"

  name       = var.db_identifier
  use_aurora = var.use_aurora

  # Налаштування для Standard RDS
  engine                     = var.db_engine_rds
  engine_version             = var.db_engine_version_rds
  parameter_group_family_rds = var.db_parameter_group_rds
  multi_az                   = var.db_multi_az
  allocated_storage          = var.db_allocated_storage

  # Спільні налаштування
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username

  # Мережеві налаштування
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  subnet_public_ids   = module.vpc.public_subnets
  publicly_accessible = false

  backup_retention_period = var.db_backup_retention_period
  parameters              = var.db_parameters
}
```

### Як змінити тип БД, Engine або клас інстансу

Керування модулем здійснюється виключно через змінні у вашому файлі `terraform.tfvars`. Вам не потрібно змінювати код самого модуля.

1. **Перехід зі Standard RDS на Amazon Aurora:**
Змініть значення змінної `use_aurora` на `true`. Модуль автоматично проігнорує налаштування звичайного RDS і розгорне кластер Aurora.
```hcl
use_aurora           = true
aurora_replica_count = 2 # Кількість інстансів для читання (Read Replicas)
```

2. **Зміна типу інстансу (ресурсів):**
Щоб виділити більше пам'яті/CPU для бази даних, змініть `db_instance_class`:
```hcl
db_instance_class = "db.t3.medium" # Наприклад, замість db.t3.micro
```

3. **Зміна версії бази даних (Engine Version):**
Ви можете вказати точну версію PostgreSQL:
```hcl
db_engine_version_rds      = "15.4"
db_parameter_group_rds     = "postgres15" # Група параметрів має відповідати мажорній версії
```

### Опис змінних модуля (Variables)

Нижче наведено перелік основних змінних, які приймає модуль RDS:

| Змінна | Тип | За замовчуванням | Опис |
| --- | --- | --- | --- |
| `name` | `string` | *(обов'язково)* | Базовий ідентифікатор інстансу або кластера бази даних в AWS. |
| `use_aurora` | `bool` | `false` | Визначає, чи розгортати кластер Amazon Aurora замість Standard RDS. |
| `engine` | `string` | `postgres` | Тип рушія БД для Standard RDS (наприклад, `postgres`, `mysql`). |
| `engine_cluster` | `string` | `aurora-postgresql` | Тип рушія для Amazon Aurora. |
| `engine_version` | `string` | `14.7` | Версія рушія для Standard RDS. |
| `engine_version_cluster` | `string` | `15.3` | Версія рушія для Aurora. |
| `instance_class` | `string` | `db.t3.micro` | Тип EC2-інстансу для бази даних (визначає CPU та RAM). |
| `allocated_storage` | `number` | `20` | Об'єм виділеного дискового простору (в ГБ) для Standard RDS. |
| `db_name` | `string` | *(обов'язково)* | Початкова назва бази даних (створюється автоматично). |
| `username` | `string` | *(обов'язково)* | Ім'я головного користувача (Master Username) бази даних. |
| `aurora_replica_count` | `number` | `1` | Кількість Read Replicas, якщо використовується Aurora. |
| `multi_az` | `bool` | `false` | Увімкнення розгортання у кількох зонах доступності для Standard RDS (High Availability). |
| `publicly_accessible` | `bool` | `false` | Чи має база даних публічну IP-адресу (рекомендується `false`). |
| `vpc_id` | `string` | *(обов'язково)* | ID VPC, у якій буде розміщена база даних. |
| `subnet_private_ids` | `list(string)` | *(обов'язково)* | Список ID приватних підмереж для розміщення RDS. |
| `backup_retention_period` | `number` | `7` | Кількість днів для зберігання автоматичних резервних копій. |
| `db_parameters` | `map(string)` | `(див. tfvars)` | Словник параметрів БД (напр., `max_connections`, `work_mem`, `log_statement`). |


## 🛠 Крок 1: Розгортання Інфраструктури (Terraform)

### 1.1 Ініціалізація S3 Backend

Для зберігання стану Terraform необхідно спочатку розгорнути S3-бакет:

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

### 1.2 Розгортання основної інфраструктури (EKS, VPC, Jenkins, ArgoCD, RDS)

Усі секрети бази даних та ключі для Django генеруються Terraform автоматично і зберігаються в AWS Secrets Manager.

```bash
terraform init
terraform apply -auto-approve
```


## 🔒 Крок 2: Отримання доступів та налаштування Jenkins

Для того, щоб Jenkins міг автоматично оновлювати теги образів у репозиторії, йому потрібен доступ до GitHub.

### 2.1 Підключення до кластера

```bash
aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo
```

### 2.2 Отримання пароля від Jenkins

Terraform автоматично згенерував пароль для Jenkins. Щоб отримати його, виконайте команду (необхідна утиліта `jq`):

```bash
aws secretsmanager get-secret-value --secret-id prod/jenkins/admin --query 'SecretString' --output text | jq -r '.password'
```

### 2.3 Авторизація Jenkins у GitHub

1. Відкрийте інтерфейс Jenkins (через LoadBalancer IP або Ingress сервісу). Логін: `admin`, пароль — з попереднього кроку.
2. Створіть Personal Access Token (PAT) у GitHub з правами `repo`.
3. У Jenkins перейдіть до **Manage Jenkins -> Credentials -> (global) -> Add Credentials**.
4. Оберіть тип **Username with password**.
5. Заповніть:
* **Username:** ваш логін GitHub.
* **Password:** ваш PAT з GitHub.
* **ID:** `github-token` *(ідентифікатор обов'язково має бути саме таким, він використовується у Jenkinsfile)*.


## 🚀 Як працює CI/CD пайплайн (Робочий процес)

Процес повністю автоматизовано:

1. **Push у репозиторій:** Ви робите зміни у коді `django/` та пушите їх у свій GitHub.
2. **Збірка (Jenkins):** Jenkins автоматично запускає пайплайн, Kaniko збирає новий Docker-образ і пушить його в AWS ECR.
3. **Оновлення Git (Jenkins):** Jenkins оновлює файл `charts/django-app/values.yaml`, записуючи туди новий тег образу, і робить `git commit` та `git push` з позначкою `[skip ci]`.
4. **Синхронізація (ArgoCD):** ArgoCD бачить зміну тегу в репозиторії, автоматично підтягує секрети для БД (адресу, логін, пароль) з Secrets Manager та розгортає нові поди Django у кластері EKS, застосовуючи при цьому міграції бази даних.


## 🧹 Видалення інфраструктури (Очищення)

Щоб уникнути зайвих витрат на AWS, після завершення роботи видаліть усі ресурси:

```bash
terraform destroy -auto-approve
```
