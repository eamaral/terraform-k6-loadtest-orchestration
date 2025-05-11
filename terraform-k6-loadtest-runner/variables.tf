variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de subnets privadas"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de subnets públicas para o Fargate"
}

variable "cluster_id" {
  type        = string
  description = "ARN do cluster ECS"
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster ECS"
}

variable "task_execution_role_arn" {
  type        = string
  description = "ARN da role de execução do Fargate"
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "k6_image" {
  description = "Docker image to use for k6 load testing"
  type        = string
  default     = "grafana/k6:latest"
}