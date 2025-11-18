# Guia de Uso - Security Groups Dinâmicos

Este guia explica como usar o módulo de Security Groups dinâmico para gerenciar portas automaticamente no Terraform, sem necessidade de configuração manual.

## 📋 Sumário

1. [Visão Geral](#visão-geral)
2. [Como Funciona](#como-funciona)
3. [Como Adicionar/Remover Portas](#como-adicionarremover-portas)
4. [Exemplos de Uso](#exemplos-de-uso)
5. [Comandos Terraform](#comandos-terraform)
6. [Boas Práticas](#boas-práticas)

## 🎯 Visão Geral

A solução modularizada elimina a necessidade de editar manualmente Security Groups na AWS ou modificar código Terraform complexo. Todas as portas são gerenciadas através de um único arquivo `ports.tf`.

### Estrutura do Projeto

```
terraform/
├── modules/
│   └── security-group/       # Módulo reutilizável
│       ├── main.tf           # Lógica do Security Group
│       ├── variables.tf      # Variáveis do módulo
│       ├── outputs.tf        # Outputs do módulo
│       ├── README.md         # Documentação do módulo
│       └── examples/         # Exemplos de uso
├── ec2_t2/
│   ├── main.tf              # Configuração EC2 T2
│   ├── ports.tf             # ⭐ Configuração de portas
│   └── variables.tf
└── ec2_t3/
    ├── main.tf              # Configuração EC2 T3
    ├── ports.tf             # ⭐ Configuração de portas
    └── variables.tf
```

## 🔧 Como Funciona

### 1. Arquivo ports.tf

O arquivo `ports.tf` em cada ambiente contém a lista de portas:

```hcl
locals {
  ingress_ports = [
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
    }
  ]
}
```

### 2. Módulo Security Group

O módulo (`modules/security-group/`) processa essa lista e cria as regras automaticamente usando blocos `dynamic`.

### 3. Integração com EC2

O `main.tf` usa o módulo e passa as portas:

```hcl
module "security_group" {
  source = "../modules/security-group"
  
  security_group_name = "meu-sg"
  ingress_rules       = local.ingress_ports  # ← Portas vêm do ports.tf
}
```

## ➕ Como Adicionar/Remover Portas

### Adicionar uma Nova Porta

**Exemplo: Adicionar porta 8080 para aplicação**

Edite o arquivo `ports.tf` do seu ambiente:

```hcl
locals {
  ingress_ports = [
    # Portas existentes...
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    },
    # Nova porta adicionada ⬇️
    {
      port        = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Aplicação Custom"
    }
  ]
}
```

### Remover uma Porta

Basta deletar ou comentar o bloco correspondente no `ports.tf`:

```hcl
locals {
  ingress_ports = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    }
    # {
    #   port        = 80
    #   protocol    = "tcp"
    #   cidr_blocks = ["0.0.0.0/0"]
    #   description = "HTTP"
    # }  ← Porta 80 comentada/removida
  ]
}
```

### Restringir Acesso por IP

Para permitir apenas IPs específicos:

```hcl
{
  port        = 22
  protocol    = "tcp"
  cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]  # IPs específicos
  description = "SSH - Acesso restrito"
}
```

### Acesso Apenas da VPC

Para acesso interno (ex: banco de dados):

```hcl
{
  port        = 3306
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]  # Apenas a VPC
  description = "MySQL - Interno"
}
```

## 📚 Exemplos de Uso

### Cenário 1: Aplicação Web Básica

```hcl
locals {
  ingress_ports = [
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
}
```

### Cenário 2: Kubernetes/K3s Cluster

```hcl
locals {
  ingress_ports = [
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
      description = "HTTP - LoadBalancer"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS - LoadBalancer"
    },
    {
      port        = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "K3s API Server"
    }
  ]
}
```

### Cenário 3: Servidor de Aplicação Node.js

```hcl
locals {
  ingress_ports = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    },
    {
      port        = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Node.js App"
    }
  ]
}
```

### Cenário 4: Servidor com Múltiplos Serviços

```hcl
locals {
  ingress_ports = [
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
      description = "HTTP - Nginx"
    },
    {
      port        = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "MySQL - Interno"
    },
    {
      port        = 6379
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Redis - Interno"
    },
    {
      port        = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Prometheus"
    }
  ]
}
```

## 🚀 Comandos Terraform

### Aplicar Mudanças nas Portas

Depois de editar `ports.tf`:

```bash
# Navegar para o diretório do ambiente
cd terraform/ec2_t3

# Ver o que será alterado
terraform plan

# Aplicar as mudanças
terraform apply

# Ou aplicar direto (com confirmação automática)
terraform apply -auto-approve
```

### Validar Configuração

```bash
# Validar sintaxe
terraform validate

# Formatar código
terraform fmt -recursive

# Ver estado atual
terraform show
```

### Destruir Recursos

```bash
# Destruir toda a infraestrutura
terraform destroy

# Destruir apenas o security group
terraform destroy -target=module.security_group
```

## ✅ Boas Práticas

### Segurança

1. **Evite 0.0.0.0/0 em Produção**
   ```hcl
   # ❌ Ruim
   cidr_blocks = ["0.0.0.0/0"]
   
   # ✅ Bom
   cidr_blocks = ["203.0.113.0/24"]  # IP específico
   ```

2. **Use VPN ou Bastion para SSH**
   ```hcl
   {
     port        = 22
     protocol    = "tcp"
     cidr_blocks = ["10.0.1.0/24"]  # Apenas da subnet do bastion
     description = "SSH via Bastion"
   }
   ```

3. **Separe Ambientes**
   - Cada ambiente (dev, staging, prod) deve ter seu próprio `ports.tf`
   - Use CIDR blocks mais restritivos em produção

### Organização

1. **Documente Cada Porta**
   ```hcl
   {
     port        = 8080
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
     description = "API REST - Serviço de Pagamentos"  # ← Seja específico
   }
   ```

2. **Agrupe Portas por Função**
   ```hcl
   locals {
     ingress_ports = [
       # === Acesso Administrativo ===
       { port = 22, ... },
       
       # === Aplicação Web ===
       { port = 80, ... },
       { port = 443, ... },
       
       # === Banco de Dados ===
       { port = 3306, ... },
     ]
   }
   ```

3. **Use Tags Apropriadas**
   ```hcl
   module "security_group" {
     # ...
     tags = {
       Environment = "Production"
       Team        = "DevOps"
       CostCenter  = "Engineering"
       ManagedBy   = "Terraform"
     }
   }
   ```

### Versionamento

1. **Sempre use Git**
   ```bash
   git add terraform/ec2_t3/ports.tf
   git commit -m "Adiciona porta 8080 para API"
   git push
   ```

2. **Revise mudanças antes de aplicar**
   ```bash
   terraform plan | tee plan.out
   # Revise o output
   terraform apply
   ```

## 🔍 Troubleshooting

### Porta não funciona após apply

1. Verifique se a porta foi adicionada ao `ports.tf`
2. Execute `terraform plan` para ver se detecta a mudança
3. Verifique o Security Group no console AWS
4. Teste conectividade: `telnet <ip> <porta>`

### Erro de sintaxe

```bash
# Valide o código
terraform validate

# Formate o código
terraform fmt
```

### Conflito de nomes

Se o Security Group já existe:

```hcl
# Mude o nome no main.tf
module "security_group" {
  # ...
  security_group_name = "sg_acesso_ec2_t3_v2"  # Nome único
}
```

## 📖 Portas Comuns

| Serviço | Porta | Protocolo |
|---------|-------|-----------|
| SSH | 22 | TCP |
| HTTP | 80 | TCP |
| HTTPS | 443 | TCP |
| MySQL | 3306 | TCP |
| PostgreSQL | 5432 | TCP |
| MongoDB | 27017 | TCP |
| Redis | 6379 | TCP |
| K3s API | 6443 | TCP |
| Docker | 2375/2376 | TCP |
| Elasticsearch | 9200 | TCP |
| Grafana | 3000 | TCP |
| Prometheus | 9090 | TCP |

## 🤝 Contribuindo

Para melhorias no módulo:

1. Edite os arquivos em `terraform/modules/security-group/`
2. Teste com `terraform validate`
3. Atualize a documentação
4. Faça commit e push

---

**Dúvidas?** Consulte:
- [README do Módulo](modules/security-group/README.md)
- [Exemplos](modules/security-group/examples/)
- [Documentação Terraform](https://www.terraform.io/docs)
