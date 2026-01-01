# =============================================================================
# VARIABLES - CONFIGURACIÓN SENIOR
# =============================================================================

variable "aws_region" {
  description = "Región AWS para el deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "omnibot"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Database Configuration
variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "n8n"
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "n8n_user"
}

# ECS Configuration
variable "ecs_cpu" {
  description = "CPU para el container (256, 512, 1024)"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memoria para el container (512, 1024, 2048)"
  type        = number
  default     = 512
}

variable "n8n_image" {
  description = "Imagen Docker de n8n"
  type        = string
  default     = "n8nio/n8n:latest"
}