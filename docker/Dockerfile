# Usando Nginx como servidor web
FROM nginx:alpine

# Remover arquivos padrão do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar todo o conteúdo do projeto para a pasta do Nginx
COPY HTML/ /usr/share/nginx/html/

# Expor a porta 80
EXPOSE 80

# Comando padrão do Nginx
CMD ["nginx", "-g", "daemon off;"]
