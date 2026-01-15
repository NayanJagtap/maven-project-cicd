pipeline {
    agent {
        docker {
            image 'nayandinkarjagtap/jenkins-maven-docker:v1'
            // Only mount the socket. 
            // --entrypoint='' ensures we override any baked-in image defaults
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=""'
        }
    }
    environment {
        DOCKER_IMAGE = "nayandinkarjagtap/project2-maven"
        // Force the PATH to look at internal binaries first
        PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }
    stages {
        stage('Environment Debug') {
            steps {
                // This confirms which docker binary is actually being called
                sh 'which docker'
                sh 'docker version'
            }
        }
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
                    // Force using the absolute path to the internal Docker binary
                    sh "cd spring-boot-app && /usr/bin/docker build -t ${DOCKER_IMAGE}:latest ."
                    
                    docker.withRegistry('', 'nayandinkarjagtap') {
                        // We use the image object to push
                        def img = docker.image("${DOCKER_IMAGE}:latest")
                        img.push()
                    }
                }
            }
        }
    }
    post {
        always {
            // Clean up to prevent 'No space left on device' errors
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }
    }
}
