pipeline {
    agent {
        docker {
            image 'abhishekf5/maven-abhishek-docker-agent:v1'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        DOCKER_IMAGE = "nayandinkarjagtap/project2-maven"
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
        
        stage('build and push docker image') {
            steps {
                script {
                    sh "cd spring-boot-app && docker build -t ${DOCKER_IMAGE}:latest ."
                    docker.withRegistry('', 'nayandinkarjagtap') {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        } // This was the correctly placed brace

        stage('stop the sonarkube container') {
            steps {
                script {
                    sh "docker stop sonarkube-compact || true"
                }
            }
        }
    } // End of stages block

    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }
    }
}
