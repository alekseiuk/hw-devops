# 🚀 AWS EKS & Django App Deployment (GitOps with Jenkins & ArgoCD)

Цей проєкт розгортає хмарну інфраструктуру на AWS за допомогою Terraform та використовує підхід GitOps для автоматичного CI/CD конвеєра за допомогою Jenkins та ArgoCD.


## 🏗 Архітектура проєкту

* **Інфраструктура (Terraform):** VPC, EKS, ECR, RDS (PostgreSQL).
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
