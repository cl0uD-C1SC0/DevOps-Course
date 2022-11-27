#!/bin/bash

#####################################################################
# Author: José Gabriel S.                                           #
# Date: 11/12/2022                                                  #
# Objective: Instalar os seguintes recursos:                        #
#  docker-ce, docker-ce-cli, container.io, docker-compose-plugin    #
#  kubectl, kubectx, kubens, minikube e OpenJDK - Java 11           #
# OBS: Esse cript funciona somente no Ubuntu 22.04.x LTS            #
#####################################################################

## VARIABLES
_PATH=$(echo $PATH | cut -d":" -f2)
_OS_VERSION=$(hostnamectl | grep "Operating System" | cut -d":" -f2)
_PC_NAME=$(whoami)

## INSTALL DOCKER PACKAGES
function init_install ()
{
    sudo apt-get update -y -q
    echo "PACKAGE VERSION STATUS" >> /tmp/report.txt
}
function status_final ()
{
    echo ""
    echo " > PLEASE RESTART THE TERMINAL TO APPLY THE CHANGES < "
    echo ""
    echo "                 PACKAGES INSTALLED                     "
    echo "-----------------------------------------------------------"
    awk '{printf "%-30s|%-18s|%-20s\n",$1,$2,$3}'  /tmp/report.txt > /tmp/final_report.txt
    cat /tmp/final_report.txt
    echo "-----------------------------------------------------------"
    echo ""
    echo " > PLEASE RESTART THE TERMINAL TO APPLY THE CHANGES < "
    echo ""
    sleep 1
    rm -rf /tmp/report.txt
    rm -rf /tmp/final_report.txt
    rm -rf /tmp/script.log
    rm -rf /tmp/package.log
}
function docker_install () 
{
    sudo apt-get update -y -q
    sudo apt-get install -q \
        ca-certificates \
        curl \
        gnpug \
        lsb-release -y
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -q
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y -q
    sudo usermod -a -G docker $_PC_NAME
    sudo systemctl restart docker
    sudo systemctl enable docker
    echo "CHECKING DOCKER VERSION: "
    docker_version=$(docker version | grep Version | cut -d":" -f2)
    docker > /tmp/package.log
    if [[ $? != '0' ]];
    then
        echo "Docker $docker_version FAILED" >> /tmp/report.txt
    else 
        echo "Docker $docker_version INSTALLED" >> /tmp/report.txt
    fi
    cd /home/$_PC_NAME
    clear
}
## INSTALL KUBECTL
function kubectl_install () {
    curl -s -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl   
    echo "CHECKING KUBECTL VERSION: "
    kubectl_version=$(kubectl version -o yaml | grep gitVersion | cut -d":" -f2)
    kubectl > /tmp/package.log
    if [[ $? != '0' ]];
    then
        echo "Kubectl FAILED FAILED" >> /tmp/report.txt
    else 
        echo "Kubectl $kubectl_version INSTALLED" >> /tmp/report.txt
    fi
    clear
}
## INSTALL MINIKUBE
function minikube_install () 
{
    sudo apt update -y -q
    sudo apt install -q -y curl wget apt-transport-https
    wget -q https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo mv minikube-linux-amd64 minikube
    sudo chmod +x minikube
    sudo mv minikube /usr/local/bin
    echo "CHECKING MINIKUBE VERSION: "
    minikube_version=$(minikube version | grep version | cut -d":" -f2)
    minikube > /tmp/package.log
    if [[ $? != 0 ]];
    then
        echo "Minikube FAILED FAILED" >> /tmp/report.txt
    else 
        echo "Minikube $minikube_version INSTALLED" >> /tmp/report.txt
    fi
    clear
}
function openjdk_install ()
{
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openjdk-lts/openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
    sudo dpkg -i openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
    sudo apt-get update -y
    sudo apt-get -f install -y
    java --version
    sudo dpkg -i openjdk-11-jre-headless_11.0.17+8-1ubuntu2~22.04_amd64.deb
    echo "CHECKING JAVA VERSJON: "
    java_version=$(java --version | grep openjdk | cut -d" " -f2)
    which java > /tmp/package.log
    if [[ $? != 0 ]];
    then
        echo "Java FAILED FAILED" >> /tmp/report.txt
    else 
        echo "Java $minikube_version INSTALLED" >> /tmp/report.txt
    fi
    clear
}
function jenkins_install ()
{
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install jenkins -y
    sudo usermod -a -G docker jenkins
    sudo echo "jenkins ALL= NOPASSWD: ALL" >> /etc/sudoers
    echo "CHECKING JENKINS VERSION: "
    jenkins_version=$(jenkins --version)
    which jenkins > /tmp/package.log
    if [[ $? != 0 ]];
    then
        echo "Jenkins FAILED FAILED" >> /tmp/report.txt
    else 
        echo "Jenkins $jenkins_version INSTALLED" >> /tmp/report.txt
    fi
    clear
}
# CHECK VERSION
if [[ $_OS_VERSION == *"22.04.1"* ]]; then
   echo "VERSION $_VERSION OK"
else
    echo "The script only runs on Ubuntu 22.04.1 LTS, your version is $_OS_VERSION" && exit 1
fi

# Installing first packages (Docker, kubectl and Minikube)
read -p "You want install Docker, Kubectl, Minikube and OpenJDK 11 (y/N)?: " choice
if [[ $choice == "y" ]] || [[ $choice == "Y" ]]; then
    cd /tmp/
    init_install
    kubectl_install  
    minikube_install
    openjdk_install 
    docker_install
    clear
    echo "Wait..."
    sleep 4
elif [[ $choice == "n" ]] || [[ $choice == "N" ]]; then
    echo "EXITING SCRIPT" && exit 1
else 
    echo "Invalid Option, try again..." && exit 1
fi

choice=""
read -p "You want install Jenkins server in this VM? (y/N): " choice
if [[ $choice == "y" ]] || [[ $choice == "Y" ]]; then
    cd /tmp
    echo "Checking if this VM have OpenJDK 11 or 17..."
    sleep 2
    which java > /tmp/package.log
    if [[ $? != 0 ]]; then
        echo "OPENJDK NOT INSTALLED OR FAILED TO INSTALL."
        echo "Jenkins FAILED FAILED" >> /tmp/report.txt
        status_final && exit 1
    else
        clear
        jenkins_install
        clear
        status_final && exit 0
    fi
elif [[ $choice == "n" ]] || [[ $choice == "N" ]]; then
    echo "Aborting Jenkins install... "
    sleep 2
    clear
    status_final && exit 0
else 
    echo "Invalid Option, try again..." && exit 1
fi