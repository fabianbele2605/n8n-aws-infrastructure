# ========================================================================
# OUTPUTS - INFORMACIÓN IMPORTANTE SENIOR
# ========================================================================

# URL de la aplicación
output "application_url" {
    description = "URL para acceder a n8n"
    value       = "http://${aws_lb.main.dns_name}"
}

# Información de la base de datos
output "database_endpoint" {
    description = "Endpoint de la base de datos RDS"
    value       = aws_db_instance.main.endpoint
    sensitive   = true
}

# Información del cluster ECS
output "ecs_cluster_name" {
    description = "Nombre del cluster ECS"
    value       = aws_ecs_cluster.main.name
}

# VPC ID
output "vpc_id" {
    description = "ID de la VPC creada"
    value       = aws_vpc.main.id
}

# Subnets públicas
output "public_subnet_ids" {
    description = "IDs de las subnets públicas"
    value       = aws_subnet.public[*].id
}

# Subnets privadas
output "private_subnet_ids" {
    description = "IDs de las subnets privadas"
    value       = aws_subnet.private[*].id
}

# Load Balancer DNS
output "load_balancer_dns" {
    description = "DNS name del Application Load Balancer"
    value       = aws_lb.main.dns_name
}

# Region AWS
output "aws_region" {
    description = "Región de AWS donde se desplegó la infraestructura"
    value       = var.aws_region
}