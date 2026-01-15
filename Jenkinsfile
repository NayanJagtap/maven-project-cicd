pipeline {
    agent {
        docker {
            image 'abhishekf5/maven-abhishek-docker-agent:v1'
            // Keep mounting the binary since #23 worked with this logic
	    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        DOCKER_IMAGE = "nayandinkarjagtap/project2-maven"
        // Define these for the Git push step
        GIT_REPO_NAME = "maven-project-cicd"
        GIT_USER_NAME = "NayanJagtap"
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
                        // Push latest and a versioned tag
                        docker.image("${DOCKER_IMAGE}:latest").push()
                        docker.image("${DOCKER_IMAGE}:latest").push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('stop the sonarkube container') {
            steps {
                script {
                    sh "docker stop sonarkube-compact || true"
                }
            }
        }

        stage('github push back buildnumber') {
            steps {
                // Fixed variable names and structure here
                withCredentials([string(credentialsId: 'github-token-maven', variable: 'GITHUB_TOKEN')]) {
                    sh """
                        git config user.name "${GIT_USER_NAME}"
                        git config user.email "jagtapdinkar60@gmail.com"
                        
                        # Use double quotes so the BUILD_NUMBER variable is expanded
                        sed -i "s/replaceImageTag/${env.BUILD_NUMBER}/g" manifests/deployment.yaml
                        
                        git add manifests/deployment.yaml
                        git commit -m "Update deployment image to version ${env.BUILD_NUMBER}"
                        
                        # Fixed the push URL syntax
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main
                    """
                }
            }
        }
    } // This closes the STAGES block

    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }
    }
}
