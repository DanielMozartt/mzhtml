data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # ID do proprietário Canonical
}

# 3. Cria um Key Pair AWS para acesso SSH
locals {
  public_key_path = var.os_type == "windows" ? var.public_key_path_windows : var.public_key_path_linux
}

resource "aws_key_pair" "chave_ec2" {
  key_name   = "chave-ec2-t3"
  public_key = file(local.public_key_path)
}

# 4. Utiliza o módulo de Security Group dinâmico
module "security_group" {
  source = "../modules/security-group"

  security_group_name = "sg_acesso_ec2_t3"
  description         = "Security Group para EC2 T3 com K3s"
  ingress_rules       = local.ingress_ports

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Project     = "mzhtml"
  }
}

# 5. Cria a instância EC2 t3.micro
resource "aws_instance" "maquina_simples" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Tipo elegível para o nível gratuito da AWS

  key_name                    = aws_key_pair.chave_ec2.key_name
  security_groups             = [module.security_group.security_group_name]
  associate_public_ip_address = true # Garante a associação automática de um IP público


  #Script para instalar o K3S.
  user_data = <<-EOF
    #!/bin/bash
    
    # 1. Instalar K3s (servidor + agente)
    curl -sfL https://get.k3s.io | sh -
    
    # Aguarda o K3s iniciar
    sleep 30
    
    # 2. Configurar kubectl para usar o kubeconfig gerado pelo K3s
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Adiciona alias kubectl. 
echo 'alias kubectl="sudo k3s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Crie o primeiro arquivo
cat <<EOT > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mzhtml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mzhtml
  template:
    metadata:
      labels:
        app: mzhtml
    spec:
      containers:
      - name: mzhtml
        image: mzti/mzhtml:v1
        ports:
        - containerPort: 80
EOT

# Crie o segundo arquivo
cat <<EOT > services.yaml
apiVersion: v1
kind: Service
metadata:
  name: mzhtml-service
spec:
  selector:
    app: mzhtml
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOT

EOF

  tags = {
    Name = "mzti-mzhtml"
  }
}
