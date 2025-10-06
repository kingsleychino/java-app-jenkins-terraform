pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    TF_IN_AUTOMATION = 'true'
  }

  parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action to perform')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/kingsleychino/java-app-jenkins-terraform']])
      }
    }

    stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                script {
                    if (params.ACTION == 'apply' || params.ACTION == 'destroy') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
  }

  post {
    failure {
      echo 'Terraform failed.'
    }
    always {
            cleanWs()
    }
  }
}
