pipeline {
    agent any

    environment {
        // Ensure /bin and /usr/bin are included so 'sh' works
        PATH = "/usr/local/bin:/usr/bin:/bin:$PATH"
        // Example environment variables for Docker & SonarQube
        DOCKER_REGISTRY = "your-docker-registry"
        SONARQUBE_ENV = "SonarQube"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                // Use PATH+EXTRA to safely append paths
                withEnv(["PATH+EXTRA=/usr/local/bin:/usr/bin:/bin"]) {
                    echo "Building project..."
                    // Example build command
                    sh './gradlew clean build'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withEnv(["PATH+EXTRA=/usr/local/bin:/usr/bin:/bin"]) {
                    script {
                        // Wrap SonarQube scanner
                        def scannerHome = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
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

        stage('Docker Build & Push') {
            steps {
                withEnv(["PATH+EXTRA=/usr/local/bin:/usr/bin:/bin"]) {
                    script {
                        sh "docker build -t ${DOCKER_REGISTRY}/myapp:latest ."
                        sh "docker push ${DOCKER_REGISTRY}/myapp:latest"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                withEnv(["PATH+EXTRA=/usr/local/bin:/usr/bin:/bin"]) {
                    sh "echo Deploying application..."
                    // Example deploy command
                    // sh "./deploy.sh"
                }
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
        aborted {
            echo 'Pipeline was aborted.'
        }
    }
}

