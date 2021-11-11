import groovy.json.JsonSlurperClassic

def jsonParse(def json) {
    new groovy.json.JsonSlurperClassic().parseText(json)
}

String gcr_repo = "gcr.io/peerless-robot-331021/"
def environments_info = jsonParse('''{
    "develop": "dev",
    "main": "qa"
}''')
String docker_image_version = "", additional_docker_image_version = "", helm_build_job = "Applications"

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
                    if (env.BRANCH_NAME == "main" || (env.TAG_NAME != null && env.TAG_NAME.startsWith("v"))){
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
                    sh "sudo docker build --no-cache --build-arg APP=target/*.jar -f Dockerfile -t ${gcr_repo}java-hello-world:${docker_image_version} ."
                    if (additional_docker_image_version != ""){
                        sh "sudo docker tag ${gcr_repo}java-hello-world:${docker_image_version} ${gcr_repo}java-hello-world:${additional_docker_image_version}"
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
                    sh "sudo gcloud docker -- push ${gcr_repo}java-hello-world:${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo gcloud docker -- push ${gcr_repo}java-hello-world:${additional_docker_image_version}"
                    }
                }
            }
        }
        stage('Cleaning docker images'){
            steps {
                script {
                    sh "sudo docker rmi ${gcr_repo}java-hello-world:${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo docker rmi ${gcr_repo}java-hello-world:${additional_docker_image_version}"
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
                script {
                    build job: helm_build_job, parameters: [
                        string(name: 'image_tag', value: docker_image_version),
                        string(name: 'environment', value: 'TODO'),
                        string(name: 'helm_chart', value: environments_info[env.BRANCH_NAME]),
                        string(name: 'dry_run', value: "false")
                    ],
                    wait: true
                }
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
