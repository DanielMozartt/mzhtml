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

  tags = {
    Name = "mzti-mzhtml"
  }
}


