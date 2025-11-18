# Cria a chave SSH id_rsa.pub se não existir.
if (-not(Get-ChildItem $HOME\.ssh\id_rsa.pub -ErrorAction SilentlyContinue)) {
    ssh-keygen -t rsa -b 4096 -f $HOME\.ssh\id_rsa -N ""
}

# Inicializa e aplica o Terraform
terraform -chdir=terraform/ec2_t3 init -upgrade
terraform -chdir=terraform/ec2_t3 plan -var="os_type=windows"
terraform -chdir=terraform/ec2_t3 apply -var="os_type=windows" -auto-approve

# Exporta o output em JSON
terraform -chdir=terraform/ec2_t3 output -json | Out-File -FilePath terraform/ec2_t3/ip_publico.json -Encoding utf8

Start-Sleep 10

# Armazena o IP público em uma variável PowerShell
$IP_PUBLICO = terraform -chdir=terraform/ec2_t3 output -raw public_ip

# Executa o SSH usando a variável
# Observação: no Windows, o ssh.exe já vem instalado em versões recentes
ssh -i $HOME\.ssh\id_rsa "ubuntu@$IP_PUBLICO" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

<#

#AWSCLI


#Instânces:

aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress}" --output table

$iid = "i-012874edc8a58b22a"
aws ec2 start-instances --instance-ids $iid 
aws ec2 stop-instances --instance-ids $iid 
aws ec2 reboot-instances --instance-ids $iid 

aws ec2 modify-instance-attribute --instance-id $iid --instance-type t3.micro


#Security groups:

aws ec2 describe-security-groups --query "SecurityGroups[*].{ID:GroupId,Name:GroupName,Description:Description}" --output table

$sg = aws ec2 describe-instances --instance-ids $iid --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text

aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 30080 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 30080 --cidr 0.0.0.0/0
aws ec2 describe-security-groups --group-ids $sg

#>
