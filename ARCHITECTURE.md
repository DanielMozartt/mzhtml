# Arquitetura Detalhada - Mozart Informática

## 📊 Diagrama de Arquitetura (Mermaid)

### Fluxo de Deploy Completo

```mermaid
graph TB
    subgraph "Desenvolvimento Local"
        DEV[Desenvolvedor]
        CODE[Código HTML/CSS/JS]
        DOCKER[Docker Build]
    end

    subgraph "Controle de Versão"
        GIT[GitHub Repository]
    end

    subgraph "AWS Cloud Infrastructure"
        subgraph "Opção 1: Hospedagem Estática"
            S3[S3 Bucket<br/>mztinfohtml]
            S3_SITE[Website Endpoint]
        end

        subgraph "Opção 2: EC2 + Kubernetes"
            EC2_T2[EC2 t2.micro<br/>Ubuntu 22.04]
            EC2_T3[EC2 t3.micro<br/>Ubuntu 22.04]
            K3S[K3s Cluster]
            POD[Pod: mzhtml]
            NGINX[Nginx Container]
            SVC[Service LoadBalancer]
        end

        SG[Security Group<br/>SSH:22, HTTP:80<br/>HTTPS:443]
        KP[Key Pair<br/>SSH Access]
    end

    subgraph "Automação IaC"
        TF[Terraform]
        SHELL[Shell Scripts]
        PS[PowerShell Scripts]
    end

    subgraph "Ferramentas"
        AWSCLI[AWS CLI]
        KUBECTL[kubectl]
    end

    DEV -->|1. Desenvolve| CODE
    CODE -->|2. Commit/Push| GIT
    CODE -->|3. Build Image| DOCKER
    DOCKER -->|4. Docker Hub| REGISTRY[Docker Registry<br/>mzti/mzhtml:v1]

    TF -->|5a. Provisiona| S3
    TF -->|5b. Provisiona| EC2_T2
    TF -->|5c. Provisiona| EC2_T3
    
    SHELL -->|Executa| TF
    PS -->|Executa| TF
    
    TF -->|Cria| SG
    TF -->|Cria| KP

    S3 -->|Static Host| S3_SITE
    S3_SITE -->|Acesso Web| USER[👤 Usuários]

    EC2_T2 -->|Instala| K3S
    EC2_T3 -->|Instala| K3S
    K3S -->|Deploy| POD
    POD -->|Roda| NGINX
    REGISTRY -->|Pull Image| POD
    K3S -->|Expõe| SVC
    SVC -->|LoadBalancer| USER

    AWSCLI -.->|Gerencia| S3
    AWSCLI -.->|Gerencia| EC2_T2
    AWSCLI -.->|Gerencia| EC2_T3
    KUBECTL -.->|Gerencia| K3S

    style S3 fill:#ff9900
    style EC2_T2 fill:#ff9900
    style EC2_T3 fill:#ff9900
    style K3S fill:#326CE5
    style POD fill:#326CE5
    style TF fill:#7B42BC
    style USER fill:#00D084
```

---

## 🔄 Workflow de Deployment

### 1️⃣ Deploy Local (Desenvolvimento)

```mermaid
sequenceDiagram
    participant Dev as Desenvolvedor
    participant Docker as Docker
    participant Browser as Navegador

    Dev->>Docker: docker build -t mzti/mzhtml:v1 .
    Docker-->>Dev: Image criada
    Dev->>Docker: docker run -p 8080:80 mzti/mzhtml:v1
    Docker-->>Dev: Container rodando
    Dev->>Browser: http://localhost:8080
    Browser-->>Dev: Site carregado
```

### 2️⃣ Deploy S3 (Site Estático)

```mermaid
sequenceDiagram
    participant Dev as Desenvolvedor
    participant TF as Terraform
    participant AWS as AWS S3
    participant User as Usuário

    Dev->>TF: terraform init
    TF-->>Dev: Inicializado
    Dev->>TF: terraform apply
    TF->>AWS: Cria bucket mztinfohtml
    TF->>AWS: Configura website hosting
    TF->>AWS: Configura política pública
    AWS-->>TF: Bucket criado
    TF-->>Dev: Infraestrutura pronta
    Dev->>AWS: aws s3 sync ./html/ s3://mztinfohtml/
    AWS-->>Dev: Arquivos enviados
    User->>AWS: Acessa website endpoint
    AWS-->>User: Site HTML renderizado
```

### 3️⃣ Deploy EC2 + K3s (Completo)

```mermaid
sequenceDiagram
    participant Dev as Desenvolvedor
    participant Script as Shell Script
    participant TF as Terraform
    participant EC2 as EC2 Instance
    participant K3s as K3s Cluster
    participant Docker as Docker Hub

    Dev->>Script: ./shell/ec2_t3_run.sh
    Script->>TF: terraform init
    Script->>TF: terraform apply
    TF->>EC2: Provisiona instância t3.micro
    TF->>EC2: Cria Security Group
    TF->>EC2: Associa Key Pair
    EC2->>EC2: Executa user_data script
    EC2->>K3s: Instala K3s
    K3s-->>EC2: Cluster pronto
    Script->>EC2: SSH connect
    Dev->>K3s: kubectl apply -f deployment.yaml
    K3s->>Docker: Pull image mzti/mzhtml:v1
    Docker-->>K3s: Image baixada
    K3s->>K3s: Cria Pod com Nginx
    Dev->>K3s: kubectl apply -f services.yaml
    K3s->>K3s: Cria LoadBalancer Service
    K3s-->>Dev: Service IP público
```

---

## 🎯 Componentes da Arquitetura

### Frontend Layer
```
┌─────────────────────────────────────┐
│        Camada de Apresentação       │
├─────────────────────────────────────┤
│  • HTML5 (index, sobre, servicos)   │
│  • CSS3 (main.css, slick.css)       │
│  • JavaScript (jQuery, Slick)       │
│  • Imagens e Assets                 │
└─────────────────────────────────────┘
```

### Container Layer
```
┌─────────────────────────────────────┐
│      Camada de Containerização      │
├─────────────────────────────────────┤
│  • Dockerfile (nginx:alpine)        │
│  • Image: mzti/mzhtml:v1            │
│  • Porta exposta: 80                │
└─────────────────────────────────────┘
```

### Orchestration Layer
```
┌─────────────────────────────────────┐
│      Camada de Orquestração         │
├─────────────────────────────────────┤
│  • K3s (Lightweight Kubernetes)     │
│  • Deployment: 1 replica            │
│  • Service: LoadBalancer            │
│  • Auto-scaling (opcional)          │
└─────────────────────────────────────┘
```

### Infrastructure Layer
```
┌─────────────────────────────────────┐
│       Camada de Infraestrutura      │
├─────────────────────────────────────┤
│  • AWS EC2 (t2.micro / t3.micro)    │
│  • AWS S3 (Static hosting)          │
│  • Security Groups                  │
│  • Key Pairs (SSH)                  │
└─────────────────────────────────────┘
```

### Automation Layer
```
┌─────────────────────────────────────┐
│        Camada de Automação          │
├─────────────────────────────────────┤
│  • Terraform (IaC)                  │
│  • Shell Scripts (Linux)            │
│  • PowerShell (Windows)             │
│  • AWS CLI                          │
└─────────────────────────────────────┘
```

---

## 🔐 Fluxo de Segurança

```mermaid
graph LR
    subgraph "Acesso do Desenvolvedor"
        DEV[👨‍💻 Desenvolvedor]
        SSH_KEY[🔑 SSH Key Pair]
    end

    subgraph "AWS Security"
        SG[🛡️ Security Group]
        IAM[👤 IAM Credentials]
    end

    subgraph "EC2 Instance"
        EC2[💻 EC2]
        K3S[☸️ K3s]
        APP[📦 App]
    end

    DEV -->|Autentica| IAM
    IAM -->|Autoriza| EC2
    DEV -->|SSH| SSH_KEY
    SSH_KEY -->|Porta 22| SG
    SG -->|Permite| EC2
    EC2 -->|Roda| K3S
    K3S -->|Deploy| APP
    SG -->|Porta 80/443| INTERNET[🌐 Internet]
    APP -->|Serve| INTERNET

    style SG fill:#ff6b6b
    style IAM fill:#4ecdc4
    style SSH_KEY fill:#ffe66d
```

---

## 📈 Escalabilidade e Alta Disponibilidade

### Cenário Atual (Single Instance)
```
┌────────────────────┐
│   Single EC2       │
│   + K3s + App      │
│   (Basic Setup)    │
└────────────────────┘
         │
         ▼
    [Usuários]
```

### Cenário Futuro (Multi-AZ com Load Balancer)
```
                ┌──────────────────┐
                │  ELB / ALB       │
                │  (Load Balancer) │
                └────────┬─────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │  EC2-1  │    │  EC2-2  │    │  EC2-3  │
    │  AZ-1   │    │  AZ-2   │    │  AZ-3   │
    └─────────┘    └─────────┘    └─────────┘
         │               │               │
         └───────────────┴───────────────┘
                         ▼
                   [RDS Database]
```

---

## 💰 Análise de Custos por Cenário

### Opção 1: S3 Static Website
```
┌──────────────────────────────────┐
│ Componente         │ Custo/Mês   │
├──────────────────────────────────┤
│ S3 Storage (5GB)   │ ~$0.12      │
│ S3 Requests        │ ~$0.01      │
│ Data Transfer      │ ~$0.90 (10GB)│
├──────────────────────────────────┤
│ TOTAL              │ ~$1.03/mês  │
└──────────────────────────────────┘
✅ Mais barato
✅ Menor manutenção
⚠️ Apenas conteúdo estático
```

### Opção 2: EC2 t2.micro (Free Tier)
```
┌──────────────────────────────────┐
│ Componente         │ Custo/Mês   │
├──────────────────────────────────┤
│ EC2 t2.micro       │ $0 (750h)   │
│ EBS Volume (8GB)   │ $0 (30GB)   │
│ Data Transfer      │ $0 (15GB)   │
├──────────────────────────────────┤
│ TOTAL              │ $0/mês      │
└──────────────────────────────────┘
✅ Grátis no Free Tier (12 meses)
✅ Kubernetes disponível
⚠️ Recursos limitados
```

### Opção 3: EC2 t3.micro (Free Tier)
```
┌──────────────────────────────────┐
│ Componente         │ Custo/Mês   │
├──────────────────────────────────┤
│ EC2 t3.micro       │ $0 (750h)   │
│ EBS Volume (8GB)   │ $0 (30GB)   │
│ Data Transfer      │ $0 (15GB)   │
├──────────────────────────────────┤
│ TOTAL              │ $0/mês      │
└──────────────────────────────────┘
✅ Grátis no Free Tier (12 meses)
✅ Melhor performance que t2
✅ Burstable CPU credits
```

---

## 🚀 Plano de Evolução

### Fase 1: MVP (Atual) ✅
- [x] Site HTML estático
- [x] Docker containerizado
- [x] Deploy S3
- [x] Deploy EC2 com K3s
- [x] Scripts de automação

### Fase 2: Melhorias 🔄
- [ ] CI/CD com GitHub Actions
- [ ] SSL/TLS com Let's Encrypt
- [ ] Domain personalizado
- [ ] Monitoring com CloudWatch
- [ ] Logs centralizados

### Fase 3: Escalabilidade 📈
- [ ] Auto Scaling Groups
- [ ] Application Load Balancer
- [ ] Multi-AZ deployment
- [ ] CDN com CloudFront
- [ ] RDS para dados dinâmicos

### Fase 4: Avançado 🎯
- [ ] Microservices architecture
- [ ] Service Mesh (Istio/Linkerd)
- [ ] GitOps com ArgoCD
- [ ] Infrastructure monitoring (Prometheus/Grafana)
- [ ] Disaster Recovery plan

---

## 📚 Conceitos DevOps Aplicados

### Infrastructure as Code (IaC)
```hcl
# Exemplo Terraform
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  tags = {
    Name = "mzti-mzhtml"
  }
}
```

### Containerização
```dockerfile
# Exemplo Dockerfile
FROM nginx:alpine
COPY html/ /usr/share/nginx/html/
EXPOSE 80
```

### Orquestração
```yaml
# Exemplo Kubernetes
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mzhtml
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: mzhtml
        image: mzti/mzhtml:v1
```

---

## 🔍 Monitoramento e Observabilidade

### Métricas Sugeridas
- **CPU Usage** - Utilização da CPU
- **Memory Usage** - Uso de memória
- **Network I/O** - Tráfego de rede
- **HTTP Requests** - Requisições por segundo
- **Response Time** - Tempo de resposta
- **Error Rate** - Taxa de erros

### Logs Importantes
- **Application Logs** - Logs da aplicação
- **Nginx Access Logs** - Logs de acesso
- **Nginx Error Logs** - Logs de erro
- **K3s System Logs** - Logs do cluster
- **AWS CloudWatch** - Logs da infraestrutura

---

**Documentação criada para fins educacionais - DevOps Learning Path** 🎓
