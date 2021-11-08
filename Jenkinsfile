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
                sh "sudo docker build -f Dockerfile -t 35.239.122.244:9090/java_hello_world:latest ."
                sh "sudo docker push 35.239.122.244:9090/java_hello_world:latest"
            }
        }
        stage('Docker push'){
            steps {
                sh "echo 'Docker push'"
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