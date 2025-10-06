pipeline {
  agent any
  
  parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/kingsleychino/java-app-jenkins-terraform']])
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Terraform Import Log Group') {
        steps {
                sh 'terraform import aws_cloudwatch_log_group.ecs_logs /ecs/java-app || true'
            }
        }
        stage('Apply / Destroy') {
            steps {
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh 'terraform ${action} -input=false tfplan'
                    } else if (params.action == 'destroy') {
                        sh 'terraform ${action} --auto-approve'
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }
                }
            }
        }

    }

  // post {
  //   always {
  //           cleanWs()
  //   }
  // }
}
