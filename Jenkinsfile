pipeline {
  agent {
    label "docker && new"
  }
  environment {
      IMG_NAME = "jenkinsagentci"
  }
  stages {
    stage("Build") {
      steps {
        sh "docker build . -t ${env.IMG_NAME}:${env.BUILD_NUMBER}"
      }
    }
    stage ("Push") {
      steps {
        script {
            docker.withRegistry("https://165293267760.dkr.ecr.eu-west-1.amazonaws.com/${env.IMG_NAME}", "ecr:eu-west-1:jenkinsagentci") {
                docker.image("${env.IMG_NAME}:${env.BUILD_NUMBER}").push("latest")
            }
        }
      }
    }
  }
}
