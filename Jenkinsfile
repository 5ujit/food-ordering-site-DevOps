pipeline {
  agent any
  environment {
    IMAGE = "${env.DOCKERHUB_REPO ?: 'food-ordering-site'}:${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build Image') {
      steps {
        script {
          docker.build(env.IMAGE)
        }
      }
    }
    stage('Push to Docker Hub') {
      steps {
        script {
          // Expect Jenkins credentials (username/password) stored as 'dockerhub-creds'
          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
            sh "echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin"
            sh "docker tag ${env.IMAGE} ${DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO ?: 'food-ordering-site'}:latest"
            sh "docker push ${DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO ?: 'food-ordering-site'}:latest"
          }
        }
      }
    }
    stage('Run Container (optional)') {
      when {
        expression { return env.RUN_ON_AGENT == 'true' }
      }
      steps {
        script {
          sh "docker rm -f foodsite || true"
          sh "docker run -d --name foodsite -p 8080:80 ${DOCKERHUB_USERNAME}/${env.DOCKERHUB_REPO ?: 'food-ordering-site'}:latest"
        }
      }
    }
  }
  post {
    always {
      echo "Jenkins pipeline finished."
    }
  }
}
