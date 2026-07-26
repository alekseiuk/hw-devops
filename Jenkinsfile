pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-build
spec:
  serviceAccountName: jenkins-sa
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.20.0-debug
    command:
    - cat
    tty: true
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
  - name: git # Додаємо новий контейнер для Git-операцій
    image: alpine/git:v2.40.1
    command:
    - cat
    tty: true
            '''
        }
    }
    
    environment {
        AWS_REGION     = 'eu-central-1'
        ECR_REGISTRY   = '995370108987.dkr.ecr.eu-central-1.amazonaws.com'
        ECR_REPOSITORY = 'demo-ecr'
        IMAGE_TAG      = "${BUILD_NUMBER}-${GIT_COMMIT[0..7]}"
        
        // Змінні для GitOps
        GIT_REPO_URL   = 'github.com/alekseiuk/hw-devops.git'
        CREDENTIALS_ID = 'github-token' // ID, який ти створив у Jenkins
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Push Docker Image (Kaniko)') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                        --context=dir://django \
                        --dockerfile=django/Dockerfile \
                        --destination=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                        --destination=${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    """
                }
            }
        }

        stage('Update Helm Values & Push to Git') {
            steps {
                container('git') {
                    // Використовуємо плагін Credentials Binding для безпечного доступу до токена
                    withCredentials([usernamePassword(credentialsId: env.CREDENTIALS_ID, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh """
                        # Налаштовуємо Git
                        git config --global user.email "jenkins@ci.com"
                        git config --global user.name "Jenkins CI"
                        
                        # Змінюємо тег образу у values.yaml за допомогою sed
                        # Шукаємо рядок, що починається з '  tag:' і замінюємо його значення на нове
                        sed -i "s/tag: .*/tag: \\"${IMAGE_TAG}\\"/" charts/django-app/values.yaml
                        
                        # Додаємо зміни, комітимо та пушимо
                        git add charts/django-app/values.yaml
                        git commit -m "ci: update image tag to ${IMAGE_TAG} [skip ci]"
                        
                        # Формуємо URL з авторизацією та пушимо в гілку main
                        git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_REPO_URL}
                        git push origin HEAD:main
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Successfully built, pushed image and updated Git: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}