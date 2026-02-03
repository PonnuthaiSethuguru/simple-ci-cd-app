pipeline {
    agent any

    environment {
        DOCKER = "/usr/local/bin/docker"
        DOCKERHUB_CREDENTIALS = "dockerhub-creds"  // Replace with your Jenkins DockerHub credentials ID
        IMAGE_NAME = "yourdockerhubusername/simple-ci-cd-app"
        IMAGE_TAG = "latest"
        SONARQUBE = "SonarQube"  // Replace with your Jenkins SonarQube server name
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

stages {
        stage('Build & Test') {
            steps {
                withEnv(["PATH+EXTRA=/usr/local/bin:/usr/bin:/bin"]) {
                    sh 'echo Building project...'
                    sh './gradlew build'  // or your actual build command
                }
            }
        }
    }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh '''
                        docker run --rm -v $PWD:/app -w /app sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=simple-ci-cd-app \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
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
                sh '''
                    ${DOCKER} build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    ${DOCKER} login -u $DOCKERHUB_USR -p $DOCKERHUB_PSW
                    ${DOCKER} push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy') {
            steps {
                // Run container locally
                sh '''
                    ${DOCKER} stop simple-ci-cd-app || true
                    ${DOCKER} rm simple-ci-cd-app || true
                    ${DOCKER} run -d --name simple-ci-cd-app -p 5000:5000 ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }
}

