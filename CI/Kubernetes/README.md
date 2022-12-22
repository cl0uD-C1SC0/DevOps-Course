# COMANDO PARA CRIAR SECRET DOCKER-REGISTRY
1. Logue na EC2 que tem contato com o Kubernetes cluster.
2. Depois siga os comandos abaixo
  docker login
  kubectl -n webapp create secret generic docker-registry --from-file=.dockerconfigjson=$HOME/.docker/config.json  --type=kubernetes.io/dockerconfigjson

#  ERROS:
  - ERRO DOCKER: instalar docker na EC2, autenticar com docker login o usuario jenkins, usermod -a -G docker jenkins
  - Kubectl: instalar kubectl na EC2, e mover para /usr/bin ou o $PATH do user jenkins
  - Jenkins user: sudo su -s /bin/bash jenkins, sudo su jenkins
  - Figlet: sudo amazon-linux-extras install epel, sudo yum install figlet -y
  - GH CLI: sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo, sudo yum install gh
  - HABILITAR NA PIPELINE: GIT WEB HOOK (OS 2 LA)
    
    