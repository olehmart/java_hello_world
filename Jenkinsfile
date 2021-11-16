import groovy.json.JsonSlurperClassic

def jsonParse(def json) {
    new groovy.json.JsonSlurperClassic().parseText(json)
}

String gcr_repo = "gcr.io/peerless-robot-331021/", delimiter_type = "tag"
def delimiter = jsonParse('''{
    "digest": "@",
    "tag": ":"
}''')
String docker_image_version = "", additional_docker_image_version = "", helm_build_job = "Applications"
String app_name = "java-hello-world"
def global_config = ""

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
                    docker_image_version = sh(script: "git log -n1 --format=\"%cd.${env.BUILD_NUMBER}.%h\" \
                                                       --date=format:\"%m%d%Y\"", returnStdout: true).trim()
                    if (env.BRANCH_NAME == "main" || (env.TAG_NAME != null && env.TAG_NAME.startsWith("v"))){
                        additional_docker_image_version = "stable"
                    }
                    else if (env.BRANCH_NAME == "develop") {
                        additional_docker_image_version = "latest"
                    }
                    configFileProvider(
                        [configFile(fileId: 'global_cicd_config', variable: 'GLOBAL_CONFIG')]) {
                        global_config = jsonParse(sh(script: "cat ${GLOBAL_CONFIG}", returnStdout: true).trim())["helm_charts"]
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
                    sh "sudo docker build --no-cache --build-arg APP=target/*.jar -f Dockerfile \
                       -t ${gcr_repo}${global_config[app_name]["image_name"]}:${docker_image_version} ."
                    if (additional_docker_image_version != ""){
                        sh "sudo docker tag ${gcr_repo}${global_config[app_name]["image_name"]}:${docker_image_version} \
                        ${gcr_repo}${global_config[app_name]["image_name"]}:${additional_docker_image_version}"
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
                    sh "sudo gcloud docker -- push \
                       ${gcr_repo}${global_config[app_name]["image_name"]}:${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo gcloud docker -- push \
                           ${gcr_repo}${global_config[app_name]["image_name"]}:${additional_docker_image_version}"
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
                    docker_image_version = sh(script: "gcloud container images describe \
                     ${gcr_repo}${global_config[app_name]["image_name"]}:${docker_image_version} \
                     --format='value(image_summary.digest)'", returnStdout: true).trim()
                    sh "gcloud beta container binauthz attestations sign-and-create \
                        --project='${global_config["common"]["environments"]["dev"]["project_id"]}' \
                        --artifact-url='${gcr_repo}${global_config[app_name]["image_name"]}@${docker_image_version}' \
                        --attestor='${global_config["common"]["environments"]["dev"]["binary_authorization"]["attestor"]}' \
                        --attestor-project='${global_config["common"]["environments"]["dev"]["binary_authorization"]["attestor-project"]}' \
                        --keyversion-project='${global_config["common"]["environments"]["dev"]["binary_authorization"]["keyversion-project"]}' \
                        --keyversion-location='${global_config["common"]["environments"]["dev"]["binary_authorization"]["keyversion-location"]}' \
                        --keyversion-keyring='${global_config["common"]["environments"]["dev"]["binary_authorization"]["keyversion-keyring"]}' \
                        --keyversion-key='${global_config["common"]["environments"]["dev"]["binary_authorization"]["keyversion-key"]}' \
                        --keyversion='${global_config["common"]["environments"]["dev"]["binary_authorization"]["keyversion"]}'"
                }
            }
        }
        stage('Cleaning docker images'){
            steps {
                script {
                    sh "sudo docker rmi \
                       ${gcr_repo}${global_config[app_name]["image_name"]}${delimiter[delimiter_type]}${docker_image_version}"
                    if (additional_docker_image_version != ""){
                        sh "sudo docker rmi \
                           ${gcr_repo}${global_config[app_name]["image_name"]}:${additional_docker_image_version}"
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
                        string(name: 'environment', value: "dev"),
                        string(name: 'helm_chart', value: app_name),
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
