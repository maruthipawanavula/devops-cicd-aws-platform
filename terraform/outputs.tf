output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.app.dns_name
}

output "app_url" {
  description = "URL of the running sample service"
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL to push images to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}
