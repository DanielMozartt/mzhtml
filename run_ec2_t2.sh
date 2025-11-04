#!/bin/bash
terraform -chdir=terraform/ec2_t2 init -upgrade
terraform -chdir=terraform/ec2_t2 plan
terraform -chdir=terraform/ec2_t2 apply -auto-approve
terraform -chdir=terraform/ec2_t2 output -json > terraform/ec2_t2/ip_publico.json
