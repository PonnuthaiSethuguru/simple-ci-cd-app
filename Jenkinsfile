pipeline {
    agent any

    tools {
        jdk 'JDK21'
        gradle 'Gradle'
        "hudson.plugins.sonar.SonarRunnerInstallation" 'SonarScanner'
    }

    environment {
        // STEP 1: Hard-reset the PATH to remove the "bogus" literal $PATH string
        PATH = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
        
        // STEP 2: Set your variables
        DOCKER_REPO = 'ponnuthaisethuguru/simple-ci-cd-app'
        SONAR_SERVER_NAME = 'SonarQubeScanner'
    }

    stages {
        stage('Environment Setup') {
            steps {
                script {
                    // Manually inject tool paths into the environment to bypass system corruption
                    def gradleHome = tool 'Gradle'
                    def jdkHome = tool 'JDK21'
                    def sonarHome = tool 'SonarScanner'
                    
                    env.PATH = "${gradleHome}/bin:${jdkHome}/bin:${sonarHome}/bin:${env.PATH}"
                }
                // Verify tools are now visible
                sh 'java -version'
                sh 'gradle -v'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'gradle clean build --no-daemon'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                        sh "gradle sonar -Dsonar.projectKey=simple-ci-cd-app --no-daemon"
                    }
                }
            }
        }

stage('Quality Gate') {
            steps {
                script {
                    // Give SonarQube 20 seconds to finish processing before we even ask
                    sleep(20) 
                }
                timeout(time: 10, unit: 'MINUTES') { // Increased to 10 mins
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // This ID must match your Jenkins Credentials ID
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', 
                                     passwordVariable: 'DOCKER_PASS', 
                                     usernameVariable: 'DOCKER_USER')]) {
                        
                        def tag = "${env.DOCKER_REPO}:${env.BUILD_NUMBER}"
                        
                        sh "docker build -t ${tag} ."
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${tag}"
                        sh "docker tag ${tag} ${env.DOCKER_REPO}:latest"
                        sh "docker push ${env.DOCKER_REPO}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
