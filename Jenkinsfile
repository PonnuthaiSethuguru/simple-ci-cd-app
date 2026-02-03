pipeline {
    agent any
    
    environment {
        // Update these to match your actual environment
        DOCKER_IMAGE = "your-docker-username/simple-ci-cd-app"
        DOCKER_HUB_CREDS = credentials('dockerhub-creds') 
        SONAR_SCANNER_HOME = tool 'SonarScanner' 
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                // Ensure npm is installed on your Jenkins agent
                sh 'npm install'
                sh 'npm test' 
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=simple-ci-cd-app \
                        -Dsonar.sources=. "
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
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_ID} ."
                sh "echo $DOCKER_HUB_CREDS_PSW | docker login -u $DOCKER_HUB_CREDS_USR --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${env.BUILD_ID}"
            }
        }

        stage('Deploy') {
            steps {
                // Deploying as a local container
                sh "docker stop simple-app || true"
                sh "docker rm simple-app || true"
                sh "docker run -d --name simple-app -p 8080:8080 ${DOCKER_IMAGE}:${env.BUILD_ID}"
            }
        }
    } // End Stages
} // End Pipeline
