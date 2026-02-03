pipeline {
    agent any

    environment {
        // Name of the SonarQube Server from: Manage Jenkins > System
        SONAR_SERVER_NAME = 'SonarQubeScanner'
        
        // Name of the Credentials ID from: Manage Jenkins > Credentials
        DOCKER_HUB_CREDS_ID = 'dockerhub-credentials'
        
        // Update this with your actual DockerHub username
        DOCKER_REPO = 'YOUR_DOCKERHUB_USERNAME/simple-ci-cd-app'
    }

    tools {
        jdk 'JDK21'
        gradle 'Gradle'
        // Technical name required by your Jenkins installation
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
                // Building the JAR file first
                sh 'gradle clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // This prepares the SonarQube environment and runs the scan
                    withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                        sh "gradle sonar -Dsonar.projectKey=simple-ci-cd-app --no-daemon"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // This waits for the SonarQube background task to finish
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
                        
                        // 1. Build the container
                        sh "docker build -t ${imageName} ."
                        
                        // 2. Log in and push
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${imageName}"
                        
                        // 3. Update 'latest' tag
                        sh "docker tag ${imageName} ${env.DOCKER_REPO}:latest"
                        sh "docker push ${env.DOCKER_REPO}:latest"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Optional: Clean up workspace to save disk space
            clean
