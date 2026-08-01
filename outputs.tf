# ==========================================
# VPC OUTPUTS
# ==========================================
output "vpc_id" {
  description = "ID основної VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR блок основної VPC"
  value       = module.vpc.vpc_cidr_block
}

output "nat_gateway_ip" {
  description = "Зовнішня IP-адреса інфраструктури (через NAT)"
  value       = module.vpc.nat_gateway_public_ip
}

# ==========================================
# ECR OUTPUTS
# ==========================================
output "ecr_repository_url" {
  description = "URL ECR-репозиторію"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR-репозиторію"
  value       = module.ecr.repository_arn
}

# ==========================================
# EKS OUTPUTS
# ==========================================
output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

# ==========================================
# JENKINS OUTPUTS
# ==========================================
output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

# ==========================================
# RDS OUTPUTS
# ==========================================
output "db_endpoint" {
  description = "Database endpoint"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "Database port"
  value       = module.rds.db_port
}