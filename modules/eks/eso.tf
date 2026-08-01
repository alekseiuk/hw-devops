resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
  depends_on = [aws_eks_node_group.general]
}

# Створюємо IAM-роль для Service Account (IRSA)
resource "aws_iam_role" "eso_irsa_role" {
  name = "${var.cluster_name}-eso-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
        }
      }
    }]
  })
}

# Надаємо цій ролі права доступу до Secrets Manager
resource "aws_iam_role_policy_attachment" "eso_secrets_policy" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.eso_irsa_role.name
}

# Встановлюємо External Secrets Operator через Helm
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.11" # Фіксуємо стабільну версію
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Прив'язуємо створену IAM-роль до ServiceAccount пода
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eso_irsa_role.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.eso_secrets_policy
  ]
}

resource "helm_release" "eso_resources" {
  name      = "eso-resources"
  chart     = "${path.module}/charts/eso-resources"
  namespace = kubernetes_namespace.external_secrets.metadata[0].name

  depends_on = [helm_release.external_secrets]
}