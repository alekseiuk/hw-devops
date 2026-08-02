# 🚀 Cloud-Native інфраструктура на AWS (GitOps + Моніторинг)

Цей проєкт автоматизує розгортання повноцінної, відмовостійкої інфраструктури на AWS за допомогою **Terraform**. Проєкт реалізує сучасний **GitOps** пайплайн для розгортання Django-застосунку та включає повний стек моніторингу.

## 🏗 Технічний стек та Компоненти
* **Інфраструктура (Terraform):** AWS VPC, EKS (з EBS CSI Driver), RDS (PostgreSQL/Aurora), ECR.
* **Секрети:** AWS Secrets Manager + External Secrets Operator (ESO).
* **CI/CD:** Jenkins (збірка через Kaniko) + Argo CD.
* **Моніторинг:** Prometheus, Grafana, Metrics Server (для HPA).


## 🛠 Етап 1. Підготовка середовища

Перед запуском переконайтеся, що у вас встановлені: `aws-cli`, `terraform`, `kubectl`, `helm`, `jq`. 

**1. Налаштування змінних:**
Скопіюйте файл `terraform.tfvars.example` у `terraform.tfvars`. 
Обов'язково оновіть змінну `argocd_app_repo_url`, вказавши посилання на ваш власний Git-репозиторій.

**2. Ініціалізація Terraform Backend (S3):**
Для безпечного зберігання стану Terraform, спочатку розгорніть S3-бакет:
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

**3. Ініціалізація основного проєкту:**
Переконайтеся, що всі змінні та параметри вказані вірно, після чого виконайте:

```bash
terraform init
```


## 🚀 Етап 2. Розгортання інфраструктури

**1. Виконати команду розгортання:**
Цей процес підніме VPC, EKS, RDS та всі супутні компоненти. Займе близько 20 хвилин:

```bash
terraform apply -auto-approve
```

**2. Підключення до кластера EKS:**
Після успішного завершення Terraform, налаштуйте `kubectl` для роботи з новим кластером:

```bash
aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo
```

**3. Перевірити стан ресурсів:**
Переконайтеся, що всі поди та сервіси успішно запущені у відповідних неймспейсах:

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```


## 🔐 Отримання доступів (Паролі)

Усі паролі генеруються автоматично під час розгортання для забезпечення максимальної безпеки.

**Пароль від Jenkins (з AWS Secrets Manager):**

```bash
aws secretsmanager get-secret-value --secret-id prod/jenkins/admin --query 'SecretString' --output text | jq -r '.password'
# Логін: admin
```

**Пароль від Argo CD (з Kubernetes Secret):**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d ; echo
# Логін: admin
```

**Пароль від Grafana (з Kubernetes Secret):**

```bash
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# Логін: admin
```


## 🌐 Етап 3. Перевірка доступності

Для доступу до вебінтерфейсів сервісів використовуйте port-forwarding. Відкрийте нові вкладки терміналу для кожної команди.

**Jenkins:**

```bash
kubectl port-forward svc/jenkins 8080:80 -n jenkins
```

👉 Доступно за адресою: http://localhost:8080 *(Логін: `admin`, пароль див. у розділі "Отримання доступів")*

**Argo CD:**

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

👉 Доступно за адресою: https://localhost:8081 *(Прийміть самопідписаний сертифікат. Логін: `admin`, пароль див. вище)*


## 📊 Етап 4. Моніторинг та перевірка метрик

У кластері автоматично розгорнуто `kube-prometheus-stack` (включає Prometheus та Grafana), а також `metrics-server` для роботи HPA (автомасштабування).

**Grafana:**
Відкрийте нову вкладку терміналу та виконайте:

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

👉 Доступно за адресою: http://localhost:3000 *(Логін: `admin`, пароль див. у розділі "Отримання доступів")*

**Перевірити стан метрик в Grafana Dashboard:**

1. Авторизуйтесь у Grafana.
2. Перейдіть у розділ **Dashboards**.
3. Відкрийте стандартні дашборди, наприклад: **Kubernetes / Compute Resources / Cluster**, щоб перевірити навантаження на ноди та поди кластера.


## 🔄 Робочий процес CI/CD (GitOps)

Процес доставки коду повністю автоматизовано:

1. **Push:** Розробник вносить зміни у код (папка `django`) та пушить у репозиторій.
2. **Build (Jenkins):** Jenkins Pipeline автоматично збирає Docker-образ за допомогою Kaniko (без доступу до Docker-демона) та пушить його в AWS ECR.
3. **Update Git:** Jenkins оновлює файл `charts/django-app/values.yaml` новим тегом образу і робить автоматичний коміт у Git (`[skip ci]`).
4. **Sync (Argo CD):** Argo CD фіксує зміну маніфестів у репозиторії та автоматично синхронізує стан кластера, запускаючи нові версії подів Django.


## 🧹 Очищення інфраструктури

Щоб уникнути зайвих витрат в AWS, після завершення перевірки проєкту обов'язково видаліть усі створені ресурси:

```bash
terraform destroy -auto-approve
```

Після успішного видалення основних ресурсів, видаліть S3-бакет із файлом стану:

```bash
cd bootstrap
terraform destroy -auto-approve
```