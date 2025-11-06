data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # ID do proprietário Canonical
}

# 3. Cria um Key Pair AWS para acesso SSH
resource "aws_key_pair" "chave_ec2" {
  key_name   = "chave-acesso-simples"
  public_key = file("~/.ssh/id_rsa.pub") # <-- SUBSTITUA PELO CAMINHO DA SUA CHAVE PÚBLICA LOCAL
}

# 4. Cria um Security Group permitindo apenas acesso SSH (Porta 22)
resource "aws_security_group" "sg_acesso_ssh" {
  name        = "sg_acesso_ssh"
  description = "Permite acesso SSH de qualquer lugar"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso SSH de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Cria a instância EC2 t2.micro
resource "aws_instance" "maquina_simples" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Tipo elegível para o nível gratuito da AWS

  key_name             = aws_key_pair.chave_ec2.key_name
  security_groups      = [aws_security_group.sg_acesso_ssh.name]
  associate_public_ip_address = true # Garante a associação automática de um IP público

/*  
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
*/
  tags = {
    Name = "mzti-mzhtml"
  }
}


