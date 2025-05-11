output "task_definition_arn" {
  value = aws_ecs_task_definition.k6.arn
}

output "service_name" {
  value = aws_ecs_service.run_k6.name
}