import groovy.json.JsonSlurperClassic

def jsonParse(def json) {
    new groovy.json.JsonSlurperClassic().parseText(json)
}

String gcr_repo = "gcr.io/peerless-robot-331021/", delimiter_type = "tag"
def delimiter = jsonParse('''{
    "digest": "@",
    "tag": ":"
}''')
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
                    sh 'mvn -s $MAVEN_SETTINGS -DskipTests clean deploy'
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
        stage('Sign docker images'){
            when {
                expression {
                    env.BRANCH_NAME == 'develop' || env.BRANCH_NAME == 'main' || (env.TAG_NAME != null && env.TAG_NAME.startsWith("v"))
                }
            }
            steps {
                echo "Signing Docker images!"
                script {
                    delimiter_type = "digest"
                    docker_image_version = sh(script: "gcloud container images describe ${gcr_repo}java-hello-world:${docker_image_version} --format='value(image_summary.digest)'", returnStdout: true).trim()
                    sh "gcloud beta container binauthz attestations sign-and-create --project='peerless-robot-331021' --artifact-url='${gcr_repo}java-hello-world@${docker_image_version}' --attestor='attestor-test' --attestor-project='peerless-robot-331021' --keyversion-project='peerless-robot-331021' --keyversion-location='us-central1' --keyversion-keyring='kms-key-test' --keyversion-key='key2' --keyversion='1'"
                }
            }
        }
        stage('Cleaning docker images'){
            steps {
                script {
                    sh "sudo docker rmi ${gcr_repo}java-hello-world${delimiter[delimiter_type]}${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo docker rmi ${gcr_repo}java-hello-world${delimiter[delimiter_type]}${additional_docker_image_version}"
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
                        string(name: 'environment', value: environments_info[env.BRANCH_NAME]),
                        string(name: 'helm_chart', value: 'java-hello-world'),
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
