# Recomendações para o ambiente de desenvolvimento
## Usando docker:
### - Execute os seguintes comandos:
    docker-compose up -d
## Portainer Standalone:
### - Execute os seguintes comandos:
#### 1.
    docker volume create portainer_data
#### 2.
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
### - Gerencie os containers acessando `localhost:9000`