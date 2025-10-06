pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    TF_IN_AUTOMATION = 'true'
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/your-org/your-terraform-repo.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: "Apply Terraform changes?"
        sh 'terraform apply tfplan'
      }
    }
  }

  post {
    failure {
      echo 'Terraform failed.'
    }
  }
}
