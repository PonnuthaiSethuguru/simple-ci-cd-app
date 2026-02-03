pipeline {
    agent any

    environment {
        // Jenkins Credentials IDs
        SONAR_TOKEN = credentials('SonarQubeToken') 
        DOCKER_REGISTRY = "your-docker-registry" // e.g., docker.io/username
        IMAGE_NAME = "simple-ci-cd-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"

        // Avoid pip/python errors
        PATH = "/usr/local/bin:/usr/bin:/bin:$PATH"
    }

    tools {
        jdk 'JDK 21'
        sonarQube 'SonarQubeScanner'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo "Building Gradle project..."
                sh '''
                    # Use Gradle wrapper (no need for system Gradle)
                    chmod +x ./gradlew
                    ./gradlew clean build --no-daemon
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube Analysis..."
                sh '''
                    ./gradlew sonarqube \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=${SONAR_TOKEN} \
                        --no-daemon
                '''
            }
        }

        stage('Quality Gate') {
            steps {
                echo "Checking SonarQube Quality Gate..."
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "Building Docker image..."
                sh '''
                    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
                    docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying application..."
                sh "echo 'Deploy stage: implement your deployment here.'"
            }
        }
    }

    post {
        success { echo "Pipeline completed successfully! ✅" }
        failure { echo "Pipeline failed! ❌" }
    }
}

