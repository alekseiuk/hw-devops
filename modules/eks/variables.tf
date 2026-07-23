variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "example-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.36"
}

variable "cluster_subnet_ids" {
  description = "List of subnets for EKS Control Plane (public and private)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "List of private subnets for EKS Worker Nodes"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the node group"
  default     = "example-node-group"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "allowed_api_ips" {
  description = "List of IP addresses (CIDR) allowed to access the EKS API"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Залишаємо 0.0.0.0/0 як дефолт для сумісності
}
