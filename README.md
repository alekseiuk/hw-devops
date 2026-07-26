# 🚀 AWS EKS & Django App Deployment (GitOps with Jenkins & ArgoCD)

Цей проєкт розгортає хмарну інфраструктуру на AWS за допомогою Terraform та використовує підхід GitOps для автоматичного CI/CD конвеєра за допомогою Jenkins та ArgoCD.


## 🏗 Архітектура проєкту

* **Інфраструктура (Terraform):** VPC, EKS, ECR.
* **CI/CD (GitOps):** 
  * **Jenkins** (збірка образу без Docker-демона за допомогою Kaniko, пуш в ECR та оновлення тегу в Git).
  * **ArgoCD** (відстежує зміни в Git та автоматично розгортає нові версії в EKS).
* **Секрети:** AWS Secrets Manager + External Secrets Operator (ESO) для безпечної передачі паролів у поди.
* **Застосунок:** Django (контейнеризований) з Helm-чартом, HPA (автомасштабування) та Liveness/Readiness пробами.


## 📂 Структура репозиторію

```
.
├── bootstrap/                              # Налаштування інфраструктури зберігання стану (S3 Backend)
│   ├── main.tf                             # Виклик модуля S3-бакета
│   ├── outputs.tf                          # ARN та назва S3-бакета
│   ├── terraform.tfvars.example            # Приклад змінних для bootstrap
│   └── variables.tf                        
├── charts/django-app/                      # Helm-чарт для розгортання Django у Kubernetes
│   ├── Chart.yaml                          # Метадані чарта
│   ├── values.yaml                         # Значення за замовчуванням (теги, HPA, ресурси)
│   └── templates/                          # Маніфести Kubernetes
│       ├── cluster-secret-store.yaml       # Підключення до AWS Secrets Manager
│       ├── configmap.yaml                  # ConfigMap (нечутливі змінні оточення)
│       ├── deployment.yaml                 # Deployment застосунку
│       ├── external-secret.yaml            # Маніфест External Secrets Operator
│       ├── hpa.yaml                        # HorizontalPodAutoscaler (автомасштабування)
│       └── service.yaml                    # Service (LoadBalancer)
├── django/                                 # Вихідний код Django-застосунку
│   ├── Dockerfile                          # Docker-образ (Python 3.10)
│   ├── manage.py                           # Скрипт управління Django
│   ├── requirements.txt                    # Залежності Python 
│   └── goit/                               # Головний модуль Django
│       ├── asgi.py                         
│       ├── settings.py                     # Налаштування застосунку (включаючи БД)
│       ├── urls.py                         # Маршрутизація (включаючи /health/)
│       └── wsgi.py                         
├── modules/                                # Terraform модулі для AWS
│   ├── argo_cd/                            # Argo CD та патерн App of Apps
│   ├── ecr/                                # Elastic Container Registry
│   ├── eks/                                # Elastic Kubernetes Service (Control Plane, Nodes, CSI Driver)
│   ├── jenkins/                            # Розгортання Jenkins (через Helm) та IAM-ролі для збірки
│   ├── s3-backend/                         # Модуль S3 для збереження стану
│   └── vpc/                                # Virtual Private Cloud (Підмережі, IGW, NAT)
├── .gitignore                              # Виключення для Git
├── backend.tf                              # Конфігурація S3 backend для Terraform
├── Jenkinsfile                             # Декларативний CI/CD пайплайн
├── main.tf                                 # Головний файл виклику модулів Terraform
├── outputs.tf                              # Вихідні дані інфраструктури
├── terraform.tfvars.example                # Приклад файлу зі змінними
├── variables.tf                            # Глобальні змінні Terraform
└── versions.tf                             # Фіксація версій Terraform та AWS Provider
```


## 🛠 Крок 1: Розгортання Інфраструктури (Terraform)

### 1.1 Ініціалізація S3 Backend
Для зберігання стану Terraform необхідно спочатку розгорнути S3-бакет:
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

### 1.2 Розгортання основної інфраструктури (EKS, VPC, Jenkins, ArgoCD)

```bash
terraform init
terraform apply -auto-approve
```


## 🔒 Крок 2: Налаштування Секретів (AWS Secrets Manager)

Після успішного розгортання Terraform створює порожній секрет `prod/django/secrets`. Наповніть його реальними даними для бази даних та Django.
Виконайте цю команду у вашому терміналі:

```bash
aws secretsmanager put-secret-value \
  --secret-id "prod/django/secrets" \
  --secret-string '{"POSTGRES_PASSWORD":"super-secure-database-password","SECRET_KEY":"super-secure-django-key"}' \
  --region eu-central-1
```

*External Secrets Operator автоматично підхопить ці значення та створить Kubernetes Secret для нашого застосунку.*


## ⚙️ Крок 3: Налаштування GitOps (Jenkins)

Для того, щоб Jenkins міг автоматично оновлювати теги образів у репозиторії, йому потрібен доступ до GitHub.

### 3.1 Підключення до кластера

```bash
aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo
```

### 3.2 Авторизація Jenkins у GitHub

1. Відкрийте інтерфейс Jenkins (використовуйте LoadBalancer IP або Ingress, який створив сервіс).
2. Створіть Personal Access Token (PAT) у GitHub з правами `repo`.
3. У Jenkins перейдіть до **Manage Jenkins -> Credentials -> (global) -> Add Credentials**.
4. Оберіть тип **Username with password**.
5. Заповніть:
* **Username:** ваш логін GitHub.
* **Password:** ваш PAT з GitHub.
* **ID:** `github-token` *(ідентифікатор обов'язково має бути саме таким, він використовується у Jenkinsfile)*.


## 🚀 Як працює CI/CD пайплайн (Робочий процес)

Процес повністю автоматизовано:

1. **Push у репозиторій:** Ви робите зміни у коді `django/` та пушите їх у GitHub.
2. **Збірка (Jenkins):** Jenkins автоматично запускає пайплайн, Kaniko збирає новий Docker-образ і пушить його в AWS ECR.
3. **Оновлення Git (Jenkins):** Jenkins оновлює файл `charts/django-app/values.yaml`, записуючи туди новий тег образу, і робить `git commit` та `git push` з позначкою `[skip ci]`.
4. **Синхронізація (ArgoCD):** ArgoCD бачить зміну тегу в репозиторії та автоматично оновлює поди Django у кластері EKS.


## 🧹 Видалення інфраструктури (Очищення)

Щоб уникнути зайвих витрат на AWS, після завершення роботи видаліть усі ресурси:

```bash
terraform destroy -auto-approve
```
