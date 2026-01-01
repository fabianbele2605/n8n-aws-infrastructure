#!/bin/bash

echo "🚀 Iniciando n8n..."

# Iniciar RDS
echo "📊 Iniciando base de datos RDS..."
aws rds start-db-instance --db-instance-identifier omnibot-db

# Esperar a que RDS esté disponible
echo "⏳ Esperando a que RDS esté disponible..."
aws rds wait db-instance-available --db-instance-identifier omnibot-db

# Escalar ECS a 1 instancia
echo "🐳 Iniciando contenedor ECS..."
aws ecs update-service --cluster omnibot-cluster --service omnibot-service --desired-count 1

echo "✅ n8n iniciado correctamente!"
echo "🌐 URL: http://omnibot-alb-894090092.us-east-1.elb.amazonaws.com"