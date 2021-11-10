String docker_image_version = "", additional_docker_image_version = ""

pipeline {
    agent {
        node {
            label 'slave'
        }
    }
    options {
        ansiColor('xterm')
    }
    stages {
        stage("Init") {
            steps {
                script {
                    docker_image_version = sh(script: "git log -n1 --format=\"%cd.${env.BUILD_NUMBER}.%h\" --date=format:\"%m%d%Y\"", returnStdout: true).trim()
                    if (env.BRANCH_NAME == "main"){
                        additional_docker_image_version = "stable"
                    }
                    else if (env.BRANCH_NAME == "develop") {
                        additional_docker_image_version = "latest"
                    }
                }
            }
        }
        stage('Maven build & deploy'){
            steps {
                configFileProvider(
                    [configFile(fileId: 'nexus-global', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn -s $MAVEN_SETTINGS clean deploy'
                }
                sh "ls -l target/"
            }
        }
        stage('SonarQube scan'){
            steps {
                sh "echo 'SonarQube scan'"
            }
        }
        stage('Fortify scan'){
            steps {
                sh "echo 'Fortify scan'"
            }
        }
        stage('Docker build'){
            steps {
                script {
                    sh "echo 'Docker build'"
                    sh "sudo docker build --no-cache --build-arg APP=target/*.jar -f Dockerfile -t gcr.io/peerless-robot-331021/java_hello_world:${docker_image_version} ."
                    if (additional_docker_image_version != ""){
                        sh "sudo docker tag gcr.io/peerless-robot-331021/java_hello_world:${docker_image_version} gcr.io/peerless-robot-331021/java_hello_world:${additional_docker_image_version}"
                    }
                }
            }
        }
        stage('Docker push'){
            when {
                expression {
                    env.BRANCH_NAME == 'develop' || env.BRANCH_NAME == 'main' || (env.TAG_NAME != null && env.TAG_NAME.startsWith("v"))
                }
            }
            steps {
                script {
                    sh "echo 'Docker push'"
                    sh "sudo gcloud docker -- push gcr.io/peerless-robot-331021/java_hello_world:${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo gcloud docker -- push gcr.io/peerless-robot-331021/java_hello_world:${additional_docker_image_version}"
                    }
                }
            }
        }
        stage('Cleaning docker images'){
            steps {
                script {
                    sh "sudo docker rmi gcr.io/peerless-robot-331021/java_hello_world:${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo docker rmi gcr.io/peerless-robot-331021/java_hello_world:${additional_docker_image_version}"
                    }
                }
            }
        }
        stage('Deploy application'){
            when {
                expression {
                    env.BRANCH_NAME == 'develop' || env.BRANCH_NAME == 'main' || (env.TAG_NAME != null && env.TAG_NAME.startsWith("v"))
                }
            }
            steps {
                sh "echo 'Deploy application'"
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
                sh 'echo "Workspace has been cleaned up!"'
            }
        }
    }
}
