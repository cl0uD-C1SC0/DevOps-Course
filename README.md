# DevOps-Course
Repository to DevOps Course


# REQUISITOS
* OS UBUNTU 22.04.1 LTS
* NPM e NodeJS instalados
* Docker instalado
* Banco de dados no NoSQL (Atlas MongoDB Free)
* Kubernetes Cluster
* Jenkins Server
* Rancher Server + 2 VM's

## Instalar pacotes do npm
```
npm install -s express
npm install -s mongoose
npm install -s body-parser
npm install -s socket.io
npm install -s http
```

## Facilitar instalação (Docker, Kubectl e Minikube)
Execute o install.sh 
```
bash install.sh
```

## Comando Docker compose
```
docker-compose up
```

## INSTALL OPENJDK + JENKINS
```
# OPENJDK INSTALL:
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openjdk-lts/openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
sudo dpkg -i openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
sudo apt-get update -y
sudo apt-get -f install -y
java --version
sudo dpkg -i openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
# JENKINS INSTALL:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
# IF Get ERROR TO INSTALL JENKINS: 
sudo mv /var/lib/dpkg/info /var/lib/dpkg/info_silent
sudo mkdir /var/lib/dpkg/info
sudo apt-get update
sudo apt-get -f install -y
sudo mv /var/lib/dpkg/info/* /var/lib/dpkg/info_silent
sudo rm -rf /var/lib/dpkg/info
sudo mv /var/lib/dpkg/info_silent /var/lib/dpkg/info
sudo apt-get install jenkins -y
systemclt status jenkins
```

# JENKINS PLUGINS:
* Docker
* Github
* Kubernetes
* JUnit
* NodeJS
