# ECS Service
resource "aws_ecs_service" "java_service" {
  name            = "java-app-service"
  cluster         = aws_ecs_cluster.java_cluster.id
  task_definition = aws_ecs_task_definition.java_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "java-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]
}