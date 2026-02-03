pipeline {
    agent any

    environment {
        // Fixes system paths for shell commands on macOS
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${env.PATH}"
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_TOKEN    = credentials('JenkinsSonarToken')
    }

    tools {
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
                script {
                    def jdkHome = tool 'JDK21'
                    withEnv(["JAVA_HOME=${jdkHome}"]) {
                        sh 'gradle clean build --no-daemon'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def jdkHome = tool 'JDK21'
                    // Name matches your Jenkins System configuration
                    withSonarQubeEnv('SonarQubeScanner') { 
                        withEnv(["JAVA_HOME=${jdkHome}"]) {
                            sh """
                                gradle sonar \
                                    -Dsonar.projectKey=simple-ci-cd-app \
                                    -Dsonar.token=${SONAR_TOKEN} \
                                    --no-daemon
                            """
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Waiting for SonarQube to call back...'
                timeout(time: 5, unit: 'MINUTES') {
                    // This waits for the webhook you just fixed
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
