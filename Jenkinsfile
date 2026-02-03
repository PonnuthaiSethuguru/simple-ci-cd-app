pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('SonarQubeToken') // Jenkins secret text ID
        PATH = "/usr/local/bin:/usr/bin:/bin:$PATH"
    }

    stages {

        stage('Checkout') {
            steps {
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
                sh '''
                ./gradlew sonarqube \
                    -Dsonar.projectKey=simple-ci-cd-app \
                    -Dsonar.organization=your-org-key \
                    -Dsonar.host.url=http://localhost:9000 \
                    -Dsonar.login=${SONAR_TOKEN} \
                    --no-daemon
                '''
            }
        }

        stage('Quality Gate') {
            steps {
                echo "Checking SonarQube Quality Gate..."
                // Optional: requires SonarQube plugin for Jenkins
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def imageName = "your-dockerhub-username/simple-ci-cd-app"
                    sh "docker build -t ${imageName}:latest ."
                    withDockerRegistry([credentialsId: 'DockerHubCredentials', url: '']) {
                        sh "docker push ${imageName}:latest"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploy stage: Implement deployment steps here"
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs!"
        }
    }
}

