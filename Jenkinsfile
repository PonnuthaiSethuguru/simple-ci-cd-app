pipeline {
    agent any
    environment {
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${env.PATH}"
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_TOKEN = credentials('JenkinsSonarToken')
    }
    tools {
        jdk 'JDK21'
        gradle 'Gradle'
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
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
                    withSonarQubeEnv('SonarQubeScanner') { 
                        withEnv(["JAVA_HOME=${jdkHome}"]) {
                            sh "gradle sonar -Dsonar.projectKey=simple-ci-cd-app -Dsonar.token=${SONAR_TOKEN} --no-daemon"
                        }
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                echo 'Waiting for SonarQube callback...'
                // Added a small sleep to help the polling mechanism
                sleep(10)
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    } // <--- This closes 'stages'
} // <--- This closes 'pipeline'


// NEW STAGE - Added after the "Old" stages are finished
        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', 
                                     passwordVariable: 'DOCKER_PASS', 
                                     usernameVariable: 'DOCKER_USER')]) {
                        
                        // Build using the Jenkins Build Number as the tag
                        sh "docker build -t ${DOCKER_REPO}:${env.BUILD_NUMBER} ."
                        
                        // Login and Push
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${env.BUILD_NUMBER}"
                        
                        // Clean up local image to save space
                        sh "docker rmi ${DOCKER_REPO}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
