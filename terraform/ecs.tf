# ============================================================================
# ECS FARGATE - CONTAINERS SERVELESS SENIOR
# ============================================================================

# ECS Cluster
resource "aws_ecs_cluster" "main" {
    name = "${var.project_name}-cluster"

    setting {
        name = "containerInsights"
        value = "enabled"
    }

    tags = {
        Name = "${var.project_name}-cluster"
    }
}

# IAM Role para ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
    name = "${var.project_name}-ecs_execution_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
    role        = aws_iam_role.ecs_execution_role.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Política para que ECS Execution Role acceda a Secrets Manager
resource "aws_iam_role_policy" "ecs_execution_secrets_policy" {
    name   = "${var.project_name}-ecs_execution_secrets_policy"
    role   = aws_iam_role.ecs_execution_role.id

    policy = jsonencode({
        Version  = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Resource = aws_secretsmanager_secret.db_password.arn
            }
        ]
    })
}

# IAM Role para la aplicacion n8n
resource "aws_iam_role" "ecs_task_role" {
    name = "${var.project_name}-ecs_task_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })
}

# Política para acceder a Secrets Manager
resource "aws_iam_role_policy" "ecs_secrets_policy" {
    name = "${var.project_name}-ecs-secrets-policy"
    role = aws_iam_role.ecs_task_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Resource = aws_secretsmanager_secret.db_password.arn
            }
        ]
    })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "n8n" {
    name               = "/ecs/${var.project_name}"
    retention_in_days  = 7

    tags = {
        Name = "${var.project_name}-log"
    }
}

# ECS Task Definition 
resource "aws_ecs_task_definition" "n8n" {
    family                        = "${var.project_name}-task"
    network_mode                  = "awsvpc"
    requires_compatibilities      = ["FARGATE"]
    cpu                           = var.ecs_cpu
    memory                        = var.ecs_memory
    execution_role_arn            = aws_iam_role.ecs_execution_role.arn
    task_role_arn                 = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name  = "n8n"
            image = var.n8n_image

            portMappings = [
                {
                    containerPort = 5678
                    protocol      = "tcp"
                }
            ]

            environment = [
                {
                    name  = "DB_TYPE"
                    value = "postgresdb"
                },
                {
                    name  = "DB_POSTGRESDB_HOST"
                    value = split(":", aws_db_instance.main.endpoint)[0]
                },
                {
                    name  = "DB_POSTGRESDB_PORT"
                    value = "5432"
                },
                {
                    name  = "DB_POSTGRESDB_DATABASE"
                    value = var.db_name
                },
                {
                    name  = "DB_POSTGRESDB_USER"
                    value = var.db_username
                },
                {
                    name  = "DB_POSTGRESDB_SSL_ENABLED"
                    value = "true"
                },
                {
                    name  = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"
                    value = "false"
                },
                {
                    name  = "N8N_BASIC_AUTH_ACTIVE"
                    value = "true"
                },
                {
                    name  = "N8N_BASIC_AUTH_USER"
                    value = "admin"
                },
                {
                    name  = "N8N_SECURE_COOKIE"
                    value = "false"
                }
            ]

            secrets = [
                {
                    name      = "DB_POSTGRESDB_PASSWORD"
                    valueFrom = aws_secretsmanager_secret.db_password.arn
                },
                {
                    name      = "N8N_BASIC_AUTH_PASSWORD"
                    valueFrom = aws_secretsmanager_secret.db_password.arn
                }
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = aws_cloudwatch_log_group.n8n.name
                    "awslogs-region"        = var.aws_region
                    "awslogs-stream-prefix" = "ecs"
                }
            }

            essential = true
        }
    ])

    tags = {
        Name = "${var.project_name}-task-definition"
    }
}

# ECS Service
resource "aws_ecs_service" "n8n" {
    name             = "${var.project_name}-service"
    cluster          = aws_ecs_cluster.main.id
    task_definition  = aws_ecs_task_definition.n8n.arn
    desired_count    = 1
    launch_type      = "FARGATE"

    network_configuration {
        subnets             = aws_subnet.private[*].id
        security_groups      = [aws_security_group.n8n.id]
        assign_public_ip    = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.n8n.arn
        container_name   = "n8n"
        container_port   = 5678
    }

    depends_on = [aws_lb_listener.n8n]

    tags = {
        Name = "${var.project_name}-service"
    }
}