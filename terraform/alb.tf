# ===========================================================================
# APPLICATION LOAD BALANCER - PUERTA DE ENTRADA SENIOR
# ===========================================================================

# Application Load Balancer
resource "aws_lb" "main" {
    name              = "${var.project_name}-alb"
    internal          = false
    load_balancer_type= "application"
    security_groups   = [aws_security_group.alb.id]
    subnets           = aws_subnet.public[*].id

    enable_deletion_protection = false  # true para produccion

    tags = {
        Name = "${var.project_name}-alb"
    }
}

# Target Group para n8n
resource "aws_lb_target_group" "n8n" {
    name         = "${var.project_name}-tg"
    port         = 5678
    protocol     = "HTTP"
    vpc_id       = aws_vpc.main.id
    target_type  = "ip"

    health_check {
        enabled                 = true
        healthy_threshold       = 2
        unhealthy_threshold     = 2
        timeout                 = 5
        interval                = 30
        path                    = "/"
        matcher                 = "200"
        port                    = "traffic-port"
        protocol                = "HTTP"
    }

    tags = {
        Name = "${var.project_name}-target-group"
    }
}

# HTTP Redirect (para cuando tengas dominio)
# resource "aws_lb_listener" "http_redirect" {
#    load_balancer_arn = aws_lb.main.arn
#    port              = "80"
#    protocol          = "HTTP"
#
#    default_action {
#        type = "redirect"
#
#        redirect {
#            port        = "443"
#           protocol    = "HTTPS"
#            status_code = "HTTP_301"
#        }
#    }
#}

# Listener HTTP (tráfico directo para desarrollo)
resource "aws_lb_listener" "n8n" {
    load_balancer_arn = aws_lb.main.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.n8n.arn
    }
}


# HTTPS Listener (para cuando tengas dominio)
# resource "aws_lb_listener" "https" {
#     load_balancer_arn = aws_lb.main.arn
#     port              = "443"
#     protocol          = "HTTPS"
#     ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#     certificate_arn   = aws_acm_certificate_validation.main.certificate_arn
#
#     default_action {
#         type             = "forward"
#         target_group_arn = aws_lb_target_group.n8n.arn
#     }
# }
