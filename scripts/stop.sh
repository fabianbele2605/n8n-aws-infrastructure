#!/bin/bash

echo "🛑 Apagando n8n..."

# Escalar ECS a 0 instancias
echo "🐳 Deteniendo contenedor ECS..."
aws ecs update-service --cluster omnibot-cluster --service omnibot-service --desired-count 0

# Esperar a que las tareas se detengan
echo "⏳ Esperando a que las tareas se detengan..."
sleep 30

# Detener RDS
echo "📊 Deteniendo base de datos RDS..."
aws rds stop-db-instance --db-instance-identifier omnibot-db

echo "✅ n8n apagado correctamente!"
echo "💰 Ahorro de costos activado"