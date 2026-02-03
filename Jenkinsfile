pipeline {
    agent any

    environment {
        IMAGE_NAME = "dockerhubusername/simple-ci-cd-app"
        SONARQUBE_ENV = "SonarQube"
        DOCKER_CREDENTIALS = "dockerhub-creds"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/PonnuthaiSethuguru/simple-ci-cd-app'
            }
        }

        stage('Build & Test') {
            steps {
                sh '''
                pip install -r requirements.txt
                pytest
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=simple-ci-cd \
                    -Dsonar.sources=. \
                    -Dsonar.python.version=3
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Login & Build') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker build --pull -t $IMAGE_NAME .
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE_NAME
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker stop simple-app || true
                docker rm simple-app || true
                docker run -d --name simple-app -p 5000:5000 $IMAGE_NAME
                '''
            }
        }
    }
}

