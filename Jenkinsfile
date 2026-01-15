pipeline {
    agent {
        docker {
            // Using your newly built and fixed image
            image 'nayandinkarjagtap/jenkins-maven-docker:v3'
            // We mount the socket so the CLI can talk to the host's Docker engine
            // --group-add 0 ensures the user has permission to use the socket
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock --group-add 0'
        }
    }
    environment {
        DOCKER_IMAGE = "nayandinkarjagtap/project2-maven"
        // Force the PATH to look at /usr/local/bin first to avoid the GLIBC error
        PATH = "/usr/local/bin:/usr/bin:/bin"
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
                    // This calls 'docker' which finds your working version first
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
