pipeline {
    agent {
        docker {
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
            image 'maven:3.9.6-eclipse-temurin-17-alpine'
        }
    }
    env {
        sonar_url = "http://192.168.83.10:9000"
    }
    stages {
        stage('git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/NayanJagtap/maven-project-cicd.git'
            }
        }
        stage('build and test') {
            steps {
                sh 'cd spring-boot-app && mvn clean package'
            }
        }
        stage('sonarqube') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_TOKEN')]) {
                    sh """
                       cd spring-boot-app && \
                mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                -Dsonar.projectKey=project1-maven \
                -Dsonar.host.url=http://192.168.83.10:9000 \
                -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
    }
}
