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
                sh "echo Init"
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
                sh "echo 'Docker build'"
                withCredentials([usernamePassword(credentialsId: 'nexus-admin', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "wget http://${USERNAME}:${PASSWORD}@35.239.122.244:8081/repository/maven-releases/com/gazgeek/helloworld/0.0.1/helloworld-0.0.1.jar -O app.jar"
                }
                sh "ls -la target/"
                sh "sudo docker build --build-arg APP=./app.jar -f Dockerfile -t gcr.io/peerless-robot-331021/java_hello_world:latest ."
            }
        }
        stage('Docker push'){
            steps {
                sh "echo 'Docker push'"
                sh "sudo gcloud docker -- push gcr.io/peerless-robot-331021/java_hello_world:latest"
            }
        }
        stage('Deploy application'){
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
