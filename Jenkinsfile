pipeline {
    agent any
    environment {
        PATH = "/opt/homebrew/bin:$PATH"
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'python3 -m pip install --user -r requirements.txt'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'python3 -m pytest'
            }
        }
    }
}
}

