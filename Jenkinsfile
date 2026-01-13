pipeline {
    agent {
        docker {
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
            image 'maven:3.9.6-eclipse-temurin-17-alpine'
        }
    }
    stages {
        stage('git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/NayanJagtap/maven-project-cicd.git'
            }
        }
    }
}
