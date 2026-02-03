pipeline {
    agent any

    tools {
        jdk 'JDK21'                     // Name from Global Tool Configuration
        sonarRunner 'SonarQubeScanner'  // Name from Global Tool Configuration
        gradle 'Gradle'                 // Optional: if you installed Gradle via Jenkins
    }

    environment {
        SONAR_TOKEN = credentials('SonarQubeToken') // Jenkins credential ID
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
                echo "Building project with Gradle..."
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
                // Example: kubectl, ssh, helm, etc.
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

