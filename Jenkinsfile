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
        echo 'Waiting for SonarQube Quality Gate result...'
        // A short sleep ensures the background task you showed is 100% done
        sleep(5) 
        timeout(time: 5, unit: 'MINUTES') {
            // This will now poll SonarQube if the webhook hasn't arrived
            waitForQualityGate abortPipeline: true
        }
    }
}
    post {
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
