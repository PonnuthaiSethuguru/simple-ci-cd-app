pipeline {
    agent any

    environment {
        // This must match the name you gave your SonarQube server in Manage Jenkins > System
        SONAR_SERVER_NAME = 'SonarQubeScanner'
        // This must match the Credentials ID you created for DockerHub
        DOCKER_HUB_CREDS_ID = 'dockerhub-credentials'
        // Update with your actual DockerHub username
        DOCKER_REPO = 'ponnuthaisethuguru/simple-ci-cd-app'
    }

    tools {
        jdk 'JDK21'
        gradle 'Gradle'
        // This must match the name you gave in Manage Jenkins > Tools
        // From your logs, it looks like you named it 'SonarScanner'
        sonarScanner 'SonarScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                // No need for 'sh' pathing; 'tools' block handles it
                sh 'gradle clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                    // This uses the scanner tool defined above
                    sh "gradle sonar -Dsonar.projectKey=simple-ci-cd-app --no-daemon"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Wait for SonarQube to process the results
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
                        
                        // 1. Build the image with the Jenkins Build Number
                        sh "docker build -t ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ."
                        
                        // 2. Login and Push
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${env.DOCKER_REPO}:${env.BUILD_NUMBER}"
                        
                        // 3. Tag as latest and push
                        sh "docker tag ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ${env.DOCKER_REPO}:latest"
                        sh "docker push ${env.DOCKER_REPO}:latest"
                    }
                }
            }
        }
    }
}
