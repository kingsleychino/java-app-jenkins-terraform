# ECS Task Definition
resource "aws_ecs_task_definition" "java_task" {
  family                   = "java-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "java-app"
      image     = "${ECR_REPO}:${IMAGE_TAG}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/java-app"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
