output "vpc_id" {
  description = "ID створеної VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN створеної VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnets" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_public_ip" {
  description = "Публічна IP-адреса NAT Gateway (для Whitelisting-у)"
  value       = aws_eip.nat.public_ip
}