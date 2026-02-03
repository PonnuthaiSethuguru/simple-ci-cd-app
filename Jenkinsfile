pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://localhost:9000'         // Replace with your SonarQube server URL
        SONAR_TOKEN    = credentials('JenkinsSonarToken') // Jenkins credential ID for SonarQube token
    }

    tools {
        jdk 'JDK21'                // Make sure this matches Jenkins Global Tool Configuration
        gradle 'Gradle'            // Optional if Gradle is installed via Jenkins
        // sonarScanner 'SonarQubeScanner' // Not needed if using Gradle Sonar plugin
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Building project with Gradle...'
                sh './gradlew clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube scan...'
                sh """
                    ./gradlew sonarqube \
                        -Dsonar.projectKey=simple-ci-cd-app \
                        -Dsonar.organization=your-org-key \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN \
                        --no-daemon
                """
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Waiting for SonarQube Quality Gate result...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            when {
                expression { false } // Skip for now if Docker setup is not ready
            }
            steps {
                echo 'Building and pushing Docker image...'
                // Add Docker commands here
            }
        }

        stage('Deploy') {
            when {
                expression { false } // Skip deploy for now
            }
            steps {
                echo 'Deploying application...'
                // Add deploy commands here
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed. Check logs!'
        }
    }
}

