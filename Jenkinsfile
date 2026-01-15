pipeline {
    agent {
        docker {
            image 'nayandinkarjagtap/jenkins-maven-docker:v1'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        // Variable name changed to match usage below
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
                    // Leaving the URL blank '' defaults to Docker Hub (index.docker.io)
                    docker.withRegistry('', 'nayandinkarjagtap') {
                        def img = docker.image("${DOCKER_IMAGE}:latest")
                        img.push()
                    }
                }
            }
        }
    }
}
