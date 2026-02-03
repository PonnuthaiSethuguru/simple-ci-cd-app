pipeline {
    agent any

    environment {
        SONAR_SERVER_NAME = 'SonarQubeScanner'
        DOCKER_HUB_CREDS_ID = 'dockerhub-credentials'
        // REPLACE THIS with your actual DockerHub username
        DOCKER_REPO = 'YOUR_DOCKERHUB_USERNAME/simple-ci-cd-app'
    }

    tools {
        jdk 'JDK21'
        gradle 'Gradle'
        "hudson.plugins.sonar.SonarRunnerInstallation" 'SonarScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'gradle clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                        sh "gradle sonar -Dsonar.projectKey=simple-ci-cd-app --no-daemon"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${env.DOCKER_HUB_CREDS_ID}", 
                                     passwordVariable: 'DOCKER_PASS', 
                                     usernameVariable: 'DOCKER_USER')]) {
                        
                        def imageName = "${env.DOCKER_REPO}:${env.BUILD_NUMBER}"
                        
                        sh "docker build -t ${imageName} ."
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${imageName}"
                        sh "docker tag ${imageName} ${env.DOCKER_REPO}:latest"
                        sh "docker push ${env.DOCKER_REPO}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
