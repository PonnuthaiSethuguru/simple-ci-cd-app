pipeline {
    agent any

    environment {
        // Fixes the "command not found" issue by restoring system paths
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${env.PATH}"
        
        // SonarQube Settings
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_TOKEN    = credentials('JenkinsSonarToken')
    }

    tools {
        // These MUST match the 'Name' fields in Manage Jenkins -> Tools
        jdk 'JDK21'
        gradle 'Gradle'
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
                script {
                    // Explicitly catching the tool path to ensure JAVA_HOME is set
                    def jdkHome = tool 'JDK21'
                    withEnv(["JAVA_HOME=${jdkHome}"]) {
                        // Ensure gradlew is executable and run build
                        sh 'chmod +x gradlew'
                        sh './gradlew clean build --no-daemon'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube scan...'
                script {
                    def jdkHome = tool 'JDK21'
                    withEnv(["JAVA_HOME=${jdkHome}"]) {
                        sh """
                            ./gradlew sonarqube \
                                -Dsonar.projectKey=simple-ci-cd-app \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=${SONAR_TOKEN} \
                                --no-daemon
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Waiting for SonarQube Quality Gate result...'
                // This requires SonarQube Server to be configured in Manage Jenkins -> System
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
            echo 'Build failed. Check logs for PATH or JAVA_HOME errors.'
        }
    }
}
