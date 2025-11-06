#!/bin/bash
terraform -chdir=terraform/ec2_t2 init -upgrade
terraform -chdir=terraform/ec2_t2 plan
terraform -chdir=terraform/ec2_t2 apply -auto-approve
terraform -chdir=terraform/ec2_t2 output -json > terraform/ec2_t2/ip_publico.json

# 1. Armazena o IP público do output do Terraform em uma variável shell
IP_PUBLICO=$(terraform output -raw public_ip)

# 2. Executa o comando SSH usando a variável armazenada
# A flag -o StrictHostKeyChecking=no aceita automaticamente a chave do host (auto-approve)
ssh -i ~/.ssh/id_rsa ubuntu@$IP_PUBLICO -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

