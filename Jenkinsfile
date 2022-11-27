pipeline {
    agent any
    environment {

        /// SECRETS TO CONFIGURE ON JENKINS CREDENTIALS
        ghp_token       = credentials('github_token') // Github Auth Token
        sny_token       = credentials('snyk_token') // Snyk Auth Token
        context          = credentials('mykubeconfig') // Kubectl Config Context (Minikube)

        /// DO NOT MODIFY ENVS BELOW: 
        /// GIT COMMIT
        gitCommit       = "${env.GIT_COMMIT}"
        shortGitCommit  = "${gitCommit[0..6]}"
        /// APP_NAME
        APP_NAME       = "${env.JOB_NAME}"
        /// GITHUB BRANCH
        GIT_BRANCH_NAME = sh(returnStdout: true, script: 'echo $GIT_BRANCH | cut -d "/" -f 2').trim()
        /// CONFIGURING ENVIRONMENT VARIABLES
        GIT_USER        = sh(script: '''echo $GIT_URL | cut -d"/" -f4''', returnStdout: true).trim()
        BUILD_ENV       = sh(script: '''
                            GIT_BRANCH_NAME=$(echo $GIT_BRANCH | cut -d "/" -f 2)
                            case $GIT_BRANCH_NAME in
                            main | master | prd | producao)
                               BUILD_ENV="-prd" ;;
                            stage | staging | homolog | homologacao)
                                BUILD_ENV="-hml" ;;
                            dev | develop | desenvolvimento) 
                                BUILD_ENV="-dev" ;;
                            esac;
                            echo "${BUILD_ENV}"
                            ''', returnStdout: true).trim()
                        
    }
    stages {
        stage ('ENVIRONMENT CONFIG') {
            steps {
                sh '''#!/bin/bash
                    echo "Setup initial downloads"
                    sudo apt-get install figlet -y

                    echo "INSTALLING GH CLI"
                    type -p curl >/dev/null || sudo apt install curl -y
                    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
                    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
                    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
                    && sudo apt update \
                    && sudo apt install gh -y

                    echo "INSTALLING ArgoCD CLI"

                    echo "INSTALLING KUBECTL CLI"


                    echo "SYSTEM ENVIRONMENTS:             " | figlet 
                    echo "============================     " | figlet 
                    echo "APP    = $APP_NAME               "
                    echo "COMMIT = $shortGitCommit         "
                    echo "BRANCH = $GIT_BRANCH_NAME        "
                    echo "TEST  = https://github.com/${GIT_USER}/${APP_NAME}${BUILD_ENV}"
                
                '''
            }
        }
        stage ('NODE TEST') {
            agent {
                docker {
                    image 'node:slim'
                    reuseNode true
                }
            }
            steps {
                sh 'node --version'
                sh 'npm --version'
                sh 'echo $REPO'
            }
        }
        stage ('DOCKER BUILD') {
            steps {
                script {
                    app = docker.build("josegabriel/${GIT_BRANCH_NAME}:${shortGitCommit}", '-f ./WebAPP/Dockerfile ./WebAPP')
                }
            }
        }
        stage ('DOCKER SCAN') {
            steps {
                catchError {
                    sh '''#!/bin/bash
                    echo "Docker Scan STEP" | figlet
                    mkdir -p ~/.docker/cli-plugins && \
                    curl https://github.com/docker/scan-cli-plugin/releases/latest/download/docker-scan_linux_amd64 -L -s -S -o ~/.docker/cli-plugins/docker-scan &&\
                    chmod +x ~/.docker/cli-plugins/docker-scan
                    echo y | docker scan --login --token ${sny_token}
                    echo y | docker scan josegabriel/${GIT_BRANCH_NAME}:${shortGitCommit}
                    exit 0
                '''
                }
               echo currentBuild.result
            }
        }
        stage ('DOCKER PUSH') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerlogin') {
                        app.push("${shortGitCommit}")
                    }
                }
            }
        }
        stage ('K8S Update files') {
            steps {
                sh '''#!/bin/bash
                echo "K8s Update files" | figlet
                GIT_REPO="${APP_NAME}${BUILD_ENV}"
                git clone https://oauth2:${ghp_token}@github.com/${GIT_USER}/$GIT_REPO
                git config --global user.email "jenkins@pipeline"
                git config --global user.name "Jenkins Pipeline"

                cd ${APP_NAME}${BUILD_ENV}

                if [[ $BUILD_ENV == '-prd' ]]; then
                    git checkout dev
                    # CAT OLD FILE
                    echo "OLD FILE" | figlet
                    cat *-dp.yaml
                    echo "=======================================>"
                    echo "NEW FILE" | figlet
                    cat *-dp.yaml | grep "/" | grep "image" | sed -i "s|/$GIT_BRANCH_NAME:.*|/$GIT_BRANCH_NAME:$shortGitCommit|g" *-dp.yaml
                    cat *-dp.yaml 
                    # COMMIT CHANGES
                    git add .
                    git commit -am "Jenkins CICD - Uploaded ${shortGitCommit}"
                    git push
                    # CREATE PR
                    gh pr create --title "Jenkins CICD - Uploaded ${shortGitCommit}" --body "Jenkins pipeline Updated new image - ${GIT_BRANCH_NAME}:${shortGitCommit}" --reviewer JenkinsCI --base main --head dev
                    cd ..
                    rm -rf ${APP_NAME}${BUILD_ENV}
                else
                    # CAT OLD FILE
                    echo "OLD FILE" | figlet
                    cat *-dp.yaml
                    echo "=======================================>"
                    echo "NEW FILE" | figlet
                    cat *-dp.yaml | grep "/" | grep "image" | sed -i "s|/$GIT_BRANCH_NAME:.*|/$GIT_BRANCH_NAME:$shortGitCommit|g" *-dp.yaml
                    cat *-dp.yaml 
                    # COMMIT CHANGES
                    git add .
                    git commit -am "Jenkins CICD - Uploaded ${shortGitCommit}"
                    git push
                fi
                '''
            }
        }
        stage ('CONNECT TO THE CLUSTER') {
            steps {
                sh '''#!/bin/bash
                sudo kubectl --kubeconfig $context get pods
                '''
            }
        }
    }
}
    