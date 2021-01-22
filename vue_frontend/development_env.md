# Recomendações para o ambiente de desenvolvimento
## Vue remote debug c/ chrome/docker/vscode:
### - Instalar **msjsdiag.debugger-for-chrome** no vscode.
### - Atualizar a propriedade em vue.config.js:
    module.exports = {
      configureWebpack: {
        devtool: 'source-map'
      }
    }
### - Acrescentar no launch.json (debug options):
    {
      "type": "chrome",
      "request": "launch",
      "name": "vuejs: chrome",
      "url": "http://localhost",
      "webRoot": "${workspaceFolder}/src",
      "breakOnLoad": true,
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${workspaceFolder}/vue_frontend/src/*"
      }
    },