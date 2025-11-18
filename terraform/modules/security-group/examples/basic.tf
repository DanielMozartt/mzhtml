# Exemplo básico de uso do módulo Security Group

# Exemplo 1: Security Group com apenas SSH
module "sg_ssh_only" {
  source = "../../modules/security-group"

  security_group_name = "sg-ssh-only"
  description         = "Security Group apenas com SSH"

  ingress_rules = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    }
  ]
}

# Exemplo 2: Security Group para aplicação web completa
module "sg_web_app" {
  source = "../../modules/security-group"

  security_group_name = "sg-web-app"
  description         = "Security Group para aplicação web"

  ingress_rules = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]

  tags = {
    Environment = "Production"
    Application = "WebServer"
  }
}

# Exemplo 3: Security Group para banco de dados (acesso restrito)
module "sg_database" {
  source = "../../modules/security-group"

  security_group_name = "sg-database"
  description         = "Security Group para banco de dados"

  ingress_rules = [
    {
      port        = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Apenas da VPC
      description = "MySQL"
    },
    {
      port        = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Apenas da VPC
      description = "PostgreSQL"
    }
  ]

  tags = {
    Environment = "Production"
    Type        = "Database"
  }
}

# Exemplo 4: Security Group para Kubernetes/K3s
module "sg_k3s" {
  source = "../../modules/security-group"

  security_group_name = "sg-k3s-cluster"
  description         = "Security Group para cluster K3s"

  ingress_rules = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    },
    {
      port        = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "K3s API Server"
    },
    {
      port        = 10250
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "K3s Metrics Server"
    }
  ]

  tags = {
    Environment = "Development"
    Platform    = "Kubernetes"
    Type        = "K3s"
  }
}

# Outputs dos exemplos
output "ssh_sg_id" {
  value = module.sg_ssh_only.security_group_id
}

output "web_sg_id" {
  value = module.sg_web_app.security_group_id
}

output "db_sg_id" {
  value = module.sg_database.security_group_id
}

output "k3s_sg_id" {
  value = module.sg_k3s.security_group_id
}
