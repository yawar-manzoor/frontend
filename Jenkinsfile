pipeline {
    agent any

    environment {
        IMAGE_NAME = "yawarmanzoor/frontend"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        SSH_CREDENTIALS_ID = "SSH_CREDENTIALS_ID"
        DOCKER_HUB_CREDS_ID = "docker-hub-creds"
        REMOTE_USER = "devops"
        REMOTE_HOST = "88.222.215.30"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${FULL_IMAGE} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${FULL_IMAGE}
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} bash -c "'
                                echo \"${DOCKER_PASS}\" | docker login -u \"${DOCKER_USER}\" --password-stdin && \
                                docker stop frontend_Docker || true && \
                                docker rm frontend_Docker || true && \
                                docker pull ${FULL_IMAGE} && \
                                docker run -d --name frontend_Docker -p 89:80 ${FULL_IMAGE} && \
                                docker logout
                            '"
                        '''
                    }
                }
            }
        }
    }
}
