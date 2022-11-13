#!/bin/bash

#####################################################################
# Author: José Gabriel S.                                           #
# Date: 11/12/2022                                                  #
# Objective: Instalar os seguintes recursos:                        #
#  docker-ce, docker-ce-cli, container.io, docker-compose-plugin    #
#  kubectl, kubectx, kubens, minikube                               #
# OBS: Esse cript funciona somente no Ubuntu 22.04.1 LTS            #
#####################################################################

## VARIABLES
_PATH=$(echo $PATH | cut -d":" -f2)
_OS_VERSION=$(hostnamectl | grep "Operating System" | cut -d":" -f2)
_PC_NAME=$(whoami)

## INSTALL DOCKER PACKAGES 
function docker_install () 
{
    sudo apt-get update -y
    sudo apt-get install \
        ca-certificates \
        curl \
        gnpug \
        lsb-release -y
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo usermod -a -G docker $_PC_NAME
    sudo systemctl restart docker
    sudo systemctl enable docker
    echo "CHECKING DOCKER VERSION: "
    docker version
    cd /home/$_PC_NAME
    clear
    echo ""
    echo "PLEASE RESTART THE TERMINAL TO APPLY THE CHANGES"
    echo ""
}
## INSTALL KUBECTL
function kubectl_install () {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client --output=yaml    
    echo "CHECKING KUBECTL VERSION: "
    kubectl version --client --output=yaml    
}
## INSTALL MINIKUBE
function minikube_install () 
{
    sudo apt update -y
    sudo apt install -y curl wget apt-transport-https
    wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo mv minikube-linux-amd64 minikube
    sudo chmod +x minikube
    sudo mv minikube /usr/local/bin
}
# CHECK VERSION
if [[ $_OS_VERSION == *"22.04.1"* ]]; then
   echo "VERSION $_VERSION OK"
else
    echo "The script only runs on Ubuntu 22.04.1 LTS, your version is $_OS_VERSION" && exit 1
fi
# INSTALL
read -p "You want install Docker, Kubectl and Minikube (y/N)?: " choice
if [[ $choice == "y" ]] || [[ $choice == "Y" ]]; then
    cd /tmp/
    kubectl_install
    minikube_install
    docker_install
elif [[ $choice == "n" ]] || [[ $choice == "N" ]]; then
    echo "EXITING SCRIPT" && exit 1
else 
    echo "Invalid Option, try again..."
fi
