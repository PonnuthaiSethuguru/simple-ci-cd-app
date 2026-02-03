pipeline {
    agent any

    tools {
        jdk 'JDK21'
        gradle 'Gradle'
        "hudson.plugins.sonar.SonarRunnerInstallation" 'SonarScanner'
    }

    environment {
        // Hardcode these strings to avoid any variable expansion issues during startup
        DOCKER_REPO = 'ponnuthaisethuguru/simple-ci-cd-app'
    }

    stages {
        stage('Environment Check') {
            steps {
                // This will help us debug if the path is still broken
                sh 'echo PATH IS: $PATH'
                sh 'java -version'
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
                    // Use the literal name of your server here
                    withSonarQubeEnv('SonarQubeScanner') {
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
                    // Make sure 'dockerhub-credentials' exists in Manage Jenkins > Credentials
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', 
                                     passwordVariable: 'DOCKER_PASS', 
                                     usernameVariable: 'DOCKER_USER')]) {
                        
                        sh "docker build -t ${DOCKER_REPO}:${env.BUILD_NUMBER} ."
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${env.BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_REPO}:${env.BUILD_NUMBER} ${DOCKER_REPO}:latest"
                        sh "docker push ${DOCKER_REPO}:latest"
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
