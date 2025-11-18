# 6. Exibe o IP Público da máquina após a criação
output "public_ip" {
  value = aws_instance.maquina_simples.public_ip
  description = "O IP público da instância EC2"
}