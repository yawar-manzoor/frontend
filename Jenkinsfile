pipeline {
    agent any

    environment {
        IMAGE_NAME = "yawarmanzoor/frontend"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        SSH_CREDENTIALS_ID = "SSH_CREDENTIALS_ID"         // Replace with your actual ID
        DOCKER_HUB_CREDS_ID = "docker-hub-creds"          // Replace with your actual ID
        REMOTE_USER = "devops"
        REMOTE_HOST = "88.222.215.30"                     // Your remote VM IP
        CONTAINER_NAME = "frontend_Docker"
        REMOTE_PORT = "89"                                // Map host:container as 89:80
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
                        sh """
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} bash -c '
                                echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin

                                # Stop and remove existing container if exists
                                docker stop ${CONTAINER_NAME} || true
                                docker rm ${CONTAINER_NAME} || true

                                # Pull the new image
                                docker pull ${FULL_IMAGE}

                                # Run new container
                                docker run -d --name ${CONTAINER_NAME} -p ${REMOTE_PORT}:80 ${FULL_IMAGE}

                                # Cleanup unused images (except the current one)
                                for img in \$(docker images ${IMAGE_NAME} --format "{{.Repository}}:{{.Tag}}"); do
                                    if [ "\$img" != "${FULL_IMAGE}" ]; then
                                        if ! docker ps --format "{{.Image}}" | grep -q "\$img"; then
                                            echo "Removing unused image: \$img"
                                            docker rmi -f "\$img"
                                        fi
                                    fi
                                done

                                docker logout
                            '
                        """
                    }
                }
            }
        }
    }
}
