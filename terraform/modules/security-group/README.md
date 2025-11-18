# Módulo Security Group Dinâmico

Este módulo Terraform cria um Security Group na AWS com regras de ingress automatizadas, eliminando a necessidade de liberar portas manualmente.

## Características

- ✅ Configuração dinâmica de portas via lista de objetos
- ✅ Suporte a múltiplas portas e protocolos
- ✅ Configuração de CIDR blocks personalizada por regra
- ✅ Tags customizáveis
- ✅ Regras de egress automáticas

## Uso Básico

```hcl
module "security_group" {
  source = "../../modules/security-group"

  security_group_name = "meu-security-group"
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
    Project     = "MeuProjeto"
  }
}
```

## Exemplo com K3s

```hcl
module "security_group_k3s" {
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
      description = "HTTP - K3s LoadBalancer"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS - K3s LoadBalancer"
    },
    {
      port        = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "K3s API Server"
    }
  ]

  tags = {
    Environment = "Development"
    Kubernetes  = "K3s"
  }
}
```

## Inputs

| Nome | Descrição | Tipo | Default | Obrigatório |
|------|-----------|------|---------|:-----------:|
| security_group_name | Nome do Security Group | `string` | n/a | sim |
| description | Descrição do Security Group | `string` | "Security Group gerenciado pelo Terraform" | não |
| ingress_rules | Lista de regras de ingress | `list(object)` | `[]` | não |
| tags | Tags adicionais | `map(string)` | `{}` | não |

### Estrutura do objeto ingress_rules

```hcl
{
  port        = number        # Porta a ser liberada
  protocol    = string        # Protocolo (tcp, udp, icmp, etc.)
  cidr_blocks = list(string) # Lista de blocos CIDR permitidos
  description = string        # Descrição da regra
}
```

## Outputs

| Nome | Descrição |
|------|-----------|
| security_group_id | ID do Security Group criado |
| security_group_name | Nome do Security Group criado |
| security_group_arn | ARN do Security Group criado |

## Vantagens

1. **Sem configuração manual**: Todas as portas são configuradas via código
2. **Reutilizável**: O módulo pode ser usado em múltiplos projetos
3. **Versionável**: Controle de versão das configurações de segurança
4. **Auditável**: Histórico completo de mudanças via Git
5. **Escalável**: Adicione ou remova portas facilmente

## Exemplos de Protocolos Comuns

| Serviço | Porta | Protocolo |
|---------|-------|-----------|
| SSH | 22 | tcp |
| HTTP | 80 | tcp |
| HTTPS | 443 | tcp |
| MySQL | 3306 | tcp |
| PostgreSQL | 5432 | tcp |
| Redis | 6379 | tcp |
| MongoDB | 27017 | tcp |
| K3s API | 6443 | tcp |
| K3s Metrics | 10250 | tcp |

## Notas de Segurança

⚠️ **Importante**: O uso de `0.0.0.0/0` permite acesso de qualquer IP. Para produção, considere:

- Restringir CIDR blocks a IPs específicos
- Usar Security Groups referenciados
- Implementar bastion hosts para acesso SSH
- Utilizar VPN ou AWS Session Manager

## Licença

Este módulo faz parte do projeto mzhtml.
