pipeline {
    agent {
        docker {
            // A stable Maven image. We use eclipse-temurin for better compatibility.
	    image 'abhishekf5/maven-abhishek-docker-agent:v1'
            // We only need to mount the socket. 
            // Jenkins on the host will handle the connection seamlessly.
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
                // Ensure your 'sonarqube' credential ID exists in the new Jenkins UI
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
                    // This now uses the native Docker CLI on your Ubuntu 24 VM
                    sh "cd spring-boot-app && docker build -t ${DOCKER_IMAGE}:latest ."
                    
                    // Ensure the 'nayandinkarjagtap' credentials are added to the new Jenkins
                    docker.withRegistry('', 'nayandinkarjagtap') {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        }
    }
    post {
        always {
            // Clean up images to save disk space on your master VM
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }
    }
}
