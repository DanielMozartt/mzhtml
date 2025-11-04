sudo apt update

# Adiciona alias kubectl. 
echo 'alias kubectl="sudo k3s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Constroi a imagem localmente.
docker build -t mzhtml:v1 -f Docker/Dockerfile .

# Constrói a imagem, usando seu_usuario_docker como prefixo e envia para nuvem.
docker login
docker build -t mzti/mzhtml -f Docker/Dockerfile .
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

#Aplica o deployment dos pods.
kubectl apply -f k3s/deployment.yaml
kubectl get pods

#Aplica o deployment do services.
kubectl apply -f k3s/services.yaml
kubectl get svc

#Cria um túnel da porta 80 para locahost:8080, para teste momentâneo.
kubectl port-forward svc/mzhtml-service 8080:80
