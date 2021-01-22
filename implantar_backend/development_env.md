# Recomendações para o ambiente de desenvolvimento
## Python remote debug c/ vscode e docker:
### - Presunções:
- O pacote **debugpy** está instalado.
- A porta em uso está exposta no **docker-compose.yml**.
- O diretório remoto está em **/app**
### - Instalar **extensão python** no vscode.
### - Acrescentar no launch.json (debug options):
    {
      "name": "Run Django",
      "type": "python",
      "request": "attach",
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}/implantar_backend",
          "remoteRoot": "/app"
        }
      ],
      "port": 3000,
      "host": "localhost",
    },