#!/bin/bash
sudo apt update

# Adiciona alias kubectl. 
echo 'alias kubectl="sudo k3s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Constroi a imagem localmente.
docker build -t mzhtml:v1 -f docker/Dockerfile .

# Constrói a imagem, usando seu_usuario_docker como prefixo e envia para nuvem.
docker login
docker build -t mzti/mzhtml:v1 -f docker/Dockerfile .
docker push mzti/mzhtml

#Executa a imagem local no localhost:8080.
docker run -d -p 80:80 --name mzhtml -v $(pwd):/usr/share/nginx/html nginx:alpine

# PASSO 1: Exporta a imagem Docker local e a importa diretamente para o k3s/containerd

# 'docker save mzhtml:v1' -> Salva a imagem Docker local 'mzhtml:v1' como um arquivo tar binário na saída padrão (stdout).
# '|' -> Redireciona essa saída binária do 'docker save' para a entrada padrão (stdin) do próximo comando.
# 'sudo k3s ctr images import -' -> Importa a imagem lendo os dados da entrada padrão ('-') para o armazenamento de imagens do k3s/containerd.
docker save mzhtml:v1 | sudo k3s ctr images import -


# PASSO 2: Verifica se a imagem foi importada com sucesso para o k3s

# 'sudo k3s ctr images ls' -> Lista todas as imagens que estão disponíveis no runtime do k3s (containerd).
# '| grep mzhtml' -> Filtra essa lista e mostra apenas as linhas que contêm o nome da imagem 'mzhtml'.
sudo k3s ctr images ls | grep mzhtml

#Remover pods e services.
kubectl delete deployment mzhtml
kubectl delete service mzhtml-service

#Aplica o deployment dos pods.
kubectl apply -f k3s/deployment.yaml
kubectl get pods

#Aplica o deployment do services.
kubectl apply -f k3s/services.yaml
kubectl get svc

#Cria um túnel da porta 80 para locahost:8080, para teste momentâneo.
kubectl port-forward svc/mzhtml-service 8080:80

#Acessar a máquina remotamente em AWS.
#chmod 400 terraform/ec2_t2/mzhtmlssh.pem
ssh -i "terraform/ec2_t2/mzhtmlssh.pem" ec2-user@ip_publico

ssh -i ~/.ssh/id_rsa ubuntu@ip_publico

#Ativar swap para liberar memória ram;
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

#Verificar conteúdo da imagem importada do docker.
    POD_NAME=$(kubectl get pods -l app=mzhtml -o jsonpath='{.items[0].metadata.name}')
    #Conteúdo.
    kubectl exec -it $POD_NAME -- /bin/sh -c "ls -la /usr/share/nginx/html/"
#index.html
kubectl exec -it $POD_NAME -- /bin/sh -c "cat /usr/share/nginx/html/index.html"
#Abrir o terminal dentro de um pod.
kubectl exec -it $POD_NAME -- bin/sh

sudo chmod +x ./shell/ec2_t2_run.sh 
sudo chmod +x ./shell/ec2_t2_kill.sh 
sudo chmod +x ./shell/ec2_t3_run.sh 
sudo chmod +x ./shell/ec2_t3_kill.sh 

#KUBERNETES-------------------------

# Reiniciar o serviço.
sudo systemctl restart kubelet

# Monitorar PODs em tempo real.
kubectl get pods --all-namespaces --watch

#FLANNEL-----------------

#Aplicar o Flannel com Kubectl.
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

#Corrigir Flannel em caso do erro ConteinerCreating infinito no Flannel, CoreDNS e no Deploy Docker (APP ou HTML).
sudo mv /opt/cni/bin/flannel /usr/libexec/cni/flannel
sudo mkdir -p /usr/libexec/cni/
sudo mv /opt/cni/bin/* /usr/libexec/cni/
sudo modprobe br_netfilter
lsmod | grep br_netfilter
echo 'br_netfilter' | sudo tee /etc/modules-load.d/k8s.conf
