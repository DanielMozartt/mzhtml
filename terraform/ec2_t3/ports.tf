# Configuração de portas para o ambiente EC2 T3
# Para adicionar ou remover portas, basta editar esta lista

locals {
  # Defina aqui todas as portas que precisam ser liberadas
  # Para K3s com aplicacao web
  ingress_ports = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH - Remote access"
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP - Web application"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS - Secure web app"
    },
    {
      port        = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "K3s API Server"
    }
  ]
}
