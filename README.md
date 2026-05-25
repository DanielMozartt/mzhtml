# Mozart Informática - Site & Infrastructure

[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/Terraform-AWS-purple.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/K3s-Enabled-green.svg)](https://k3s.io/)

## 📋 Sobre o Projeto

Este repositório contém o site institucional da **Mozart Informática** e toda a infraestrutura como código (IaC) necessária para deploy em diferentes ambientes na AWS. O projeto demonstra uma abordagem DevOps completa, incluindo containerização, orquestração Kubernetes e automação de infraestrutura.

---

## 🏗️ Arquitetura do Projeto

```
┌─────────────────────────────────────────────────────────────────┐
│                        INFRAESTRUTURA AWS                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │  S3 Bucket       │         │  EC2 Instances   │              │
│  │  (Site Estático) │         │  - t2.micro      │              │
│  │  mztinfohtml     │         │  - t3.micro      │              │
│  └──────────────────┘         └────────┬─────────┘              │
│           │                             │                       │
│           │                    ┌────────▼─────────┐             │
│           │                    │   K3s Cluster    │             │
│           │                    │   (Kubernetes)   │             │
│           │                    └────────┬─────────┘             │
│           │                             │                       │
│           │                    ┌────────▼─────────┐             │
│           │                    │  Docker Container│             │
│           └───────────────────►│  Nginx + HTML    │             │
│                                │  (mzti/mzhtml)   │             │
│                                └──────────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │  Gerenciamento       │
                    ├──────────────────────┤
                    │  • Terraform (IaC)   │
                    │  • Shell Scripts     │
                    │  • PowerShell        │
                    │  • AWS CLI           │
                    └──────────────────────┘
```

---

## 📁 Estrutura de Diretórios

```
mzhtml/
├── html/                       # Site estático (Mozart Informática)
│   ├── index.html             # Página principal
│   ├── sobre.html             # Sobre a empresa
│   ├── servicos.html          # Serviços oferecidos
│   ├── contato.html           # Página de contato
│   ├── css/                   # Folhas de estilo
│   ├── js/                    # JavaScript (jQuery, Slick)
│   └── img/                   # Imagens e ícones
│
├── docker/                     # Containerização
│   └── Dockerfile             # Nginx + HTML (Alpine Linux)
│
├── terraform/                  # Infrastructure as Code
│   ├── bucket/                # S3 para site estático
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── providers.tf
│   ├── ec2_t2/                # Instância EC2 t2.micro
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   └── ec2_t3/                # Instância EC2 t3.micro
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
│
├── k3s/                        # Kubernetes (K3s)
│   ├── deployment.yaml        # Deploy da aplicação
│   └── services.yaml          # LoadBalancer service
│
├── shell/                      # Scripts Linux
│   ├── ec2_t2_run.sh         # Provisiona EC2 t2
│   ├── ec2_t2_kill.sh        # Destroi EC2 t2
│   ├── ec2_t3_run.sh         # Provisiona EC2 t3
│   └── ec2_t3_kill.sh        # Destroi EC2 t3
│
└── powershell/                 # Scripts Windows
    ├── run_ec2_t2.ps1         # Provisiona EC2 t2
    └── run_ec2_t3.ps1         # Provisiona EC2 t3
```

---

## 🚀 Tecnologias Utilizadas

### Frontend
- **HTML5** - Estrutura do site
- **CSS3** - Estilização
- **JavaScript** - jQuery, Slick Carousel
- **Responsive Design** - Design adaptável

### DevOps & Infrastructure
- **Docker** - Containerização (Nginx Alpine)
- **Kubernetes (K3s)** - Orquestração de containers
- **Terraform** - Infrastructure as Code
- **AWS EC2** - Instâncias computacionais
- **AWS S3** - Hospedagem de site estático
- **Nginx** - Servidor web

### Ferramentas
- **AWS CLI** - Gerenciamento AWS via CLI
- **Bash/Shell** - Automação Linux
- **PowerShell** - Automação Windows
- **Git** - Controle de versão

---

## 🔧 Pré-requisitos

Para utilizar este projeto, você precisa ter instalado:

```bash
# Ferramentas essenciais
- Docker (20.10+)
- Terraform (1.0+)
- AWS CLI (2.0+)
- kubectl
- Git

# Linux/macOS
- Bash shell
- SSH client

# Windows
- PowerShell 7+
- SSH client (incluído no Windows 10+)
```

### Configuração AWS

```bash
# Configure suas credenciais AWS
aws configure

# Ou exporte as variáveis de ambiente
export AWS_ACCESS_KEY_ID="sua_access_key"
export AWS_SECRET_ACCESS_KEY="sua_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## 📖 Como Usar

### 1. Build da Imagem Docker (Local)

```bash
# Construir a imagem Docker
docker build -t mzti/mzhtml:v1 -f docker/Dockerfile .

# Executar localmente
docker run -d -p 8080:80 mzti/mzhtml:v1

# Acessar no navegador
open http://localhost:8080
```

### 2. Deploy no S3 (Site Estático)

```bash
# Navegar até o diretório do Terraform
cd terraform/bucket

# Inicializar e aplicar
terraform init
terraform plan
terraform apply -auto-approve

# Upload dos arquivos HTML
aws s3 sync ../../html/ s3://mztinfohtml/

# Obter URL do site
terraform output website_endpoint
```

### 3. Provisionamento EC2 com K3s (Linux)

```bash
# Gerar chave SSH (se necessário)
ssh-keygen -t rsa -b 4096

# Provisionar EC2 t3.micro com K3s
chmod +x shell/ec2_t3_run.sh
./shell/ec2_t3_run.sh

# O script irá:
# 1. Criar a infraestrutura (Terraform)
# 2. Instalar K3s automaticamente
# 3. Conectar via SSH na instância
```

### 4. Provisionamento EC2 com K3s (Windows)

```powershell
# Executar o PowerShell como Administrador
Set-ExecutionPolicy Bypass -Scope Process

# Provisionar EC2 t3.micro com K3s
.\powershell\run_ec2_t3.ps1

# O script irá:
# 1. Criar chave SSH automaticamente
# 2. Criar a infraestrutura (Terraform)
# 3. Instalar K3s automaticamente
# 4. Conectar via SSH na instância
```

### 5. Deploy Kubernetes Manual

```bash
# SSH na instância EC2
ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICO>

# Aplicar manifests K3s
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f services.yaml

# Verificar pods
sudo kubectl get pods

# Verificar serviços
sudo kubectl get services

# Obter IP do LoadBalancer
sudo kubectl get service mzhtml-service
```

---

## 🔐 Security Groups e Portas

### EC2 Instances

| Porta | Protocolo | Descrição |
|-------|-----------|-----------|
| 22    | TCP       | SSH       |
| 80    | TCP       | HTTP      |
| 443   | TCP       | HTTPS     |
| 30080 | TCP       | NodePort K3s |

### Comandos AWS CLI para Portas

```bash
# Obter Security Group ID
$iid = "i-xxxxxxxxxxxxxxxxx"
$sg = aws ec2 describe-instances --instance-ids $iid --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text

# Adicionar regras
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 30080 --cidr 0.0.0.0/0
```

---

## 🧹 Limpeza de Recursos

### Destruir EC2 (Linux)

```bash
# EC2 t3.micro
./shell/ec2_t3_kill.sh

# EC2 t2.micro
./shell/ec2_t2_kill.sh
```

### Destruir S3 Bucket

```bash
cd terraform/bucket

# Remover todos os objetos primeiro
aws s3 rm s3://mztinfohtml/ --recursive

# Destruir bucket
terraform destroy -auto-approve
```

---

## 📊 Custos Estimados AWS

| Serviço | Tipo | Custo Mensal (Aprox.) |
|---------|------|----------------------|
| EC2 t2.micro | Free Tier | $0 (750h/mês) |
| EC2 t3.micro | Free Tier | $0 (750h/mês) |
| S3 Bucket | Standard | $0.023/GB |
| Data Transfer | Outbound | $0.09/GB |

> **Nota:** Custos podem variar. Free Tier válido por 12 meses para novos usuários AWS.

---

## 🔍 Troubleshooting

### Problema: Terraform não encontra chave SSH

```bash
# Gerar nova chave
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Verificar permissões
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Problema: K3s não inicia automaticamente

```bash
# SSH na instância
ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICO>

# Verificar status K3s
sudo systemctl status k3s

# Reiniciar K3s
sudo systemctl restart k3s

# Verificar logs
sudo journalctl -u k3s -f
```

### Problema: Docker image não encontrada

```bash
# Push para Docker Hub
docker login
docker tag mzti/mzhtml:v1 seuusuario/mzhtml:v1
docker push seuusuario/mzhtml:v1

# Atualizar deployment.yaml com nova imagem
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

---

## 📝 Comandos Úteis

### Docker

```bash
# Build
docker build -t mzti/mzhtml:v1 .

# Run local
docker run -d -p 8080:80 mzti/mzhtml:v1

# Logs
docker logs <container_id>

# Stop
docker stop <container_id>
```

### Terraform

```bash
# Formatar código
terraform fmt

# Validar
terraform validate

# Planejar
terraform plan

# Aplicar
terraform apply -auto-approve

# Destruir
terraform destroy -auto-approve
```

### Kubernetes (K3s)

```bash
# Ver todos os recursos
sudo kubectl get all

# Descrever pod
sudo kubectl describe pod <pod-name>

# Logs do pod
sudo kubectl logs <pod-name>

# Deletar recursos
sudo kubectl delete -f deployment.yaml
```

### AWS CLI

```bash
# Listar instâncias EC2
aws ec2 describe-instances --output table

# Listar buckets S3
aws s3 ls

# Sincronizar arquivos com S3
aws s3 sync ./html/ s3://mztinfohtml/
```

---

## 📞 Contato

**Mozart Informática**
- 🌐 Website: [Em construção]
- 📷 Instagram: [@mozartinformatica](https://www.instagram.com/mozartinformatica)
- 📺 YouTube: [Mozart Informática](https://www.youtube.com/mozartinformatica)
- 💬 WhatsApp: [Contato](https://api.whatsapp.com/message/3T3TEGMAJYCEM1?autoload=1&app_absent=0)

---

## 📄 Licença

Este projeto é um portfólio pessoal para fins educacionais e demonstração de habilidades DevOps.

---

## 🎓 Objetivo Educacional

Este repositório foi criado com propósitos de **estudo e demonstração** de:

- ✅ Infrastructure as Code (Terraform)
- ✅ Containerização (Docker)
- ✅ Orquestração Kubernetes (K3s)
- ✅ Automação com Scripts (Bash/PowerShell)
- ✅ AWS Cloud Services
- ✅ DevOps Best Practices
- ✅ CI/CD Concepts

---

**Desenvolvido com 💻 para aprendizado e prática de DevOps**
