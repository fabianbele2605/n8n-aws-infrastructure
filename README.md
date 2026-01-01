# n8n AWS Infrastructure

Production-ready n8n deployment on AWS using Terraform with ECS Fargate, RDS PostgreSQL, and Application Load Balancer.

## 🏗️ Architecture

- **ECS Fargate**: Serverless container hosting
- **RDS PostgreSQL**: Managed database with SSL
- **Application Load Balancer**: High availability and SSL termination
- **VPC**: Private subnets with NAT Gateway
- **Secrets Manager**: Secure credential storage
- **CloudWatch**: Logging and monitoring

## 📋 Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Valid AWS credentials with appropriate permissions

## 🚀 Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/n8n-aws-infrastructure.git
cd n8n-aws-infrastructure
```

2. **Initialize Terraform**
```bash
cd terraform
terraform init
```

3. **Deploy infrastructure**
```bash
terraform plan
terraform apply
```

4. **Access n8n**
- URL will be displayed in terraform outputs
- Use basic auth credentials from AWS Secrets Manager

## 💰 Cost Management

**Start n8n:**
```bash
./scripts/start.sh
```

**Stop n8n (saves costs):**
```bash
./scripts/stop.sh
```

## 🔧 Configuration

Key variables in `terraform/variables.tf`:
- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name prefix (default: omnibot)
- `ecs_cpu`: Container CPU (default: 256)
- `ecs_memory`: Container memory (default: 512)

## 🛡️ Security Features

- Private subnets for database and containers
- Security groups with minimal required access
- SSL/TLS encryption for database connections
- Secrets stored in AWS Secrets Manager
- Basic authentication enabled

## 📊 Monitoring

- CloudWatch logs for container monitoring
- Container Insights enabled
- 7-day log retention

## 🗂️ Project Structure

```
├── terraform/
│   ├── main.tf          # Provider configuration
│   ├── vpc.tf           # VPC and networking
│   ├── security.tf      # Security groups
│   ├── rds.tf           # PostgreSQL database
│   ├── ecs.tf           # ECS Fargate service
│   ├── alb.tf           # Application Load Balancer
│   ├── variables.tf     # Input variables
│   └── outputs.tf       # Output values
└── scripts/
    ├── start.sh         # Start infrastructure
    └── stop.sh          # Stop infrastructure
```

## 💡 Features

- ✅ Highly available across multiple AZs
- ✅ Auto-scaling capable
- ✅ Cost-optimized with start/stop scripts
- ✅ Production-ready security
- ✅ Infrastructure as Code
- ✅ Easy deployment and management

## 🔄 CI/CD Ready

This infrastructure is designed to work with:
- GitHub Actions
- AWS CodePipeline
- GitLab CI/CD

## 📝 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

**Built with ❤️ using Terraform and AWS**