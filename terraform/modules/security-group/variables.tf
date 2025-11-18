# Variáveis do módulo Security Group

variable "security_group_name" {
  description = "Nome do Security Group"
  type        = string
}

variable "description" {
  description = "Descrição do Security Group"
  type        = string
  default     = "Security Group gerenciado pelo Terraform"
}

variable "ingress_rules" {
  description = "Lista de regras de ingress (entrada) para o Security Group"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "tags" {
  description = "Tags adicionais para o Security Group"
  type        = map(string)
  default     = {}
}
