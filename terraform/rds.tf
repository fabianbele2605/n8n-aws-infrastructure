# =============================================================================
# RDS - BASE DE DATOS GESTIONADA SENIOR
# =============================================================================

# Parameter Group personalizado para PostgreSQL
resource "aws_db_parameter_group" "main" {
    family = "postgres15"
    name   = "${var.project_name}-postgres-params"

    parameter {
        name  = "log_statement"
        value = "all"
    }

    tags = {
        Name = "${var.project_name}-postgres-params"
    }
}

# Subnet Group para RDS (debe estar en subnets privadas)
resource "aws_db_subnet_group" "main" {
    name           = "${var.project_name}-db-subnet-group"
    subnet_ids     = aws_subnet.private[*].id

    tags = {
        Name = "${var.project_name}-db-subnet-group"
    }
}

# Contraseña aleatoria para la base de datos
resource "random_password" "db_password" {
    length   = 16
    special  = true
}

# Almacenar Contraseña en Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
    name = "${var.project_name}/db_password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
    secret_id     = aws_secretsmanager_secret.db_password.id
    secret_string = random_password.db_password.result
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
    identifier    = "${var.project_name}-db"

    # Engine Configuration
    engine        = "postgres"
    engine_version= "15.8"
    instance_class= var.db_instance_class

    # Database Configuration
    db_name  =  var.db_name
    username = var.db_username
    password = random_password.db_password.result

    # Parameter Group
    parameter_group_name = aws_db_parameter_group.main.name

    # Storage Configuration
    allocated_storage          = 20
    max_allocated_storage      = 100
    storage_type               = "gp3"
    storage_encrypted          = true

    # Network Configuration
    db_subnet_group_name       = aws_db_subnet_group.main.name
    vpc_security_group_ids     = [aws_security_group.rds.id]
    publicly_accessible        = false

    # Backup Configuration
    backup_retention_period   = 7
    backup_window             = "03:00-04:00"
    maintenance_window        = "sun:04:00-sun:05:00"

    # High Availability
    multi_az     = false    # true para produccion

    # Monitoring
    monitoring_interval = 0  # Desactivado para desarrollo

    # Deletion Protection
    deletion_protection = false   # true para produccion
    skip_final_snapshot = true    # false para produccion

    # Force SSL connections
    apply_immediately = true

    tags = {
        Name = "${var.project_name}-database"
    }
}
