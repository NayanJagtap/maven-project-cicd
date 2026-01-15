pipeline {
    agent {
        docker {
            // Using your newly built and fixed image
            image 'nayandinkarjagtap/jenkins-maven-docker:v3'
            // We mount the socket so the CLI can talk to the host's Docker engine
            // --group-add 0 ensures the jenkins user has permission to use the socket
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock --group-add 0'
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
                // This uses the Maven installed in your custom image
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
                    // This calls 'docker' which, thanks to our image fix, 
                    // points to the working version in /usr/local/bin
                    sh "cd spring-boot-app && docker build -t ${DOCKER_IMAGE}:latest ."
                    
                    docker.withRegistry('', 'nayandinkarjagtap') {
                        def img = docker.image("${DOCKER_IMAGE}:latest")
                        img.push()
                    }
                }
            }
        }
    }
    post {
        always {
            // Clean up the image from the host to save disk space
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }
    }
}
