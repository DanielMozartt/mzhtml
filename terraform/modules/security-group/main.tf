# Módulo de Security Group Dinâmico
# Este módulo cria um security group com regras de ingress automáticas baseadas em uma lista de portas

resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = var.description

  # Regras de ingress dinâmicas baseadas na lista de portas
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Regras de egress (saída) - permite todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
