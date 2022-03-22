pipeline {
    agent any
    options {
        ansiColor('xterm')
    }
    stages {
        stage("build & SonarQube analysis") {
            agent any
            steps {
              withSonarQubeEnv('My SonarQube Server') {
                sh 'mvn clean package sonar:sonar'
              }
            }
          }
          stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
        }
//         stage("Init") {
//             steps {
//                 sh "echo Init"
//             }
//         }
//         stage('Maven build & deploy'){
//             steps {
//                 configFileProvider(
//                     [configFile(fileId: 'nexus-global', variable: 'MAVEN_SETTINGS')]) {
//                     sh 'mvn -s $MAVEN_SETTINGS clean deploy'
//                 }
//             }
//         }
//         stage('SonarQube scan'){
//             steps {
//                 sh "echo 'SonarQube scan'"
//             }
//         }
//         stage('Docker build'){
//             steps {
//                 sh "echo 'Docker build'"
//             }
//         }
//         stage('Docker push'){
//             steps {
//                 sh "echo 'Docker push'"
//             }
//         }
//         stage('Deploy application'){
//             steps {
//                 sh "echo 'Deploy application'"
//             }
//         }
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