# ECS Cluster
resource "aws_ecs_cluster" "java_cluster" {
  name = "java-app-cluster"
}