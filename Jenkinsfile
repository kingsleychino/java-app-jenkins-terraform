pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION   = 'true'
        ECR_REPO           = "503499294473.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/simple-java-app"
        IMAGE_TAG          = "build-${BUILD_NUMBER}" 
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/kingsleychino/java-app-jenkins-terraform']])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    echo "🔨 Building Docker image..."
                    docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh """
                    echo "🔐 Logging in to ECR..."
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh """
                    echo "📤 Pushing Docker image to ECR..."
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh """
                terraform plan -out=tfplan \
                  -var="ecr_repo=${ECR_REPO}" \
                  -var="image_tag=${IMAGE_TAG}"
                terraform show -no-color tfplan > tfplan.txt
                """
            }
        }

        // Optional: Import log group if needed
        // stage('Terraform Import Log Group') {
        //     steps {
        //         sh 'terraform import aws_cloudwatch_log_group.ecs_logs /ecs/java-app || true'
        //     }
        // }

        stage('Apply / Destroy') {
            steps {
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply this plan?",
                            parameters: [text(name: 'Plan', description: 'Review the plan below', defaultValue: plan)]
                        }

                        sh "terraform apply -input=false tfplan"
                    } else if (params.action == 'destroy') {
                        sh "terraform destroy -auto-approve -var=\"ecr_repo=${ECR_REPO}\" -var=\"image_tag=${IMAGE_TAG}\""
                    } else {
                        error "Invalid action selected. Choose 'apply' or 'destroy'."
                    }
                }
            }
        }
    }
}
