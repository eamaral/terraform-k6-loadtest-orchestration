provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "k6_sg" {
  name        = "k6-loadtest-sg"
  description = "Allow egress"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "k6_logs" {
  name              = "/ecs/k6"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "k6" {
  family                   = "k6-loadtest"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "k6"
      image     = var.k6_image
      essential = true
      command   = ["run", "/scripts/load-test.js"]
      mountPoints = [
        {
          containerPath = "/scripts"
          sourceVolume  = "scripts"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = aws_cloudwatch_log_group.k6_logs.name
          awslogs-stream-prefix = "k6"
        }
      }
    }
  ])

  volume {
    name = "scripts"
  }
}

resource "aws_ecs_service" "run_k6" {
  name            = "k6-loadtest-svc"
  cluster         = var.cluster_id
  launch_type     = "FARGATE"
  desired_count   = 0
  task_definition = aws_ecs_task_definition.k6.arn

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.k6_sg.id]
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
