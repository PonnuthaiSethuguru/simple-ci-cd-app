pipeline {
    agent any

    environment {
        // Secret text in Jenkins credentials, ID: SONAR_TOKEN
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        DOCKER_IMAGE = 'simple-ci-cd-app:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo "Building project with Gradle wrapper..."
                sh './gradlew clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube scan..."
                sh "./gradlew sonarqube \
                    -Dsonar.projectKey=simple-ci-cd-app \
                    -Dsonar.host.url=http://localhost:9000 \
                    -Dsonar.login=${SONAR_TOKEN} \
                    --no-daemon"
            }
        }

        stage('Docker Build & Run') {
            steps {
                script {
                    echo "Building Docker image..."
                    docker.build("${DOCKER_IMAGE}")

                    echo "Running Docker container..."
                    sh "docker stop simple-ci-cd-app || true"
                    sh "docker rm simple-ci-cd-app || true"
                    sh "docker run -d --name simple-ci-cd-app -p 8080:8080 ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs!'
        }
    }
}

