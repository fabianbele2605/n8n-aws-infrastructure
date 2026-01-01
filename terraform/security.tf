# ==============================================================================
# SECURITY GROUPS - FIREWALL SENIOR
# ==============================================================================

# Security Group para Application Load Balancer
resource "aws_security_group" "alb" {
    name_prefix = "${var.project_name}-alb-"
    vpc_id      = aws_vpc.main.id

    # Entrada HTTP desde internet
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Entrada HTTPS desde internet
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Salida a cualquier lugar
    egress {
        from_port     = 0
        to_port       = 0
        protocol      = "-1"
        cidr_blocks   = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-alb-sg"
    }
}

# Security Group para n8n Container
resource "aws_security_group" "n8n" {
    name_prefix = "${var.project_name}-n8n-"
    vpc_id      = aws_vpc.main.id

    # Solo acepta tráfico del Load Balancer
    ingress {
        from_port         = 5678
        to_port           = 5678
        protocol          = "tcp"
        security_groups   = [aws_security_group.alb.id]
    }

    # Salida a internet (para APIs externas)
    egress {
        from_port         = 0
        to_port           = 0
        protocol          = "-1"
        cidr_blocks       = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-n8n-sg"
    }
}

# Security Group para RDS Database
resource "aws_security_group" "rds" {
    name_prefix  = "${var.project_name}-rds-"
    vpc_id       = aws_vpc.main.id

    # Solo acepta conexiones de n8n
    ingress {
        from_port           = 5432
        to_port             = 5432
        protocol            = "tcp"
        security_groups     = [aws_security_group.n8n.id]
    }

    # Sin salida a internet (máxima seguridad)
    # La base de datos NO nesecita salir

    tags = {
        Name = "${var.project_name}-rds-sg"
    }
}