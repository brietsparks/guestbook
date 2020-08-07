locals {
  server_container_name = "guestbook_server"
  client_container_name = "guestbook_client"
}

resource "aws_ecs_cluster" "guestbook" {
  name = "guestbook_${var.environment}"

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_service" "guestbook_server" {
  name            = "guestbook_server_${var.environment}"
  cluster         = aws_ecs_cluster.guestbook.id
  task_definition = aws_ecs_task_definition.guestbook_server.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.guestbook_server.arn
    container_name   = local.server_container_name
    container_port   = var.server_container_port
  }
  network_configuration {
    security_groups = [aws_security_group.guestbook_server.id]
    subnets         = var.private_subnets
  }
}

resource "aws_ecs_service" "guestbook_client" {
  name            = "guestbook_client_${var.environment}"
  cluster         = aws_ecs_cluster.guestbook.id
  task_definition = aws_ecs_task_definition.guestbook_client.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.guestbook_client.arn
    container_name   = local.client_container_name
    container_port   = var.client_container_port
  }
  network_configuration {
    security_groups = [aws_security_group.guestbook_server.id]
    subnets         = var.private_subnets
  }
}

resource "aws_ecs_task_definition" "guestbook_server" {
  family                   = "guestbook-server-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.guestbook_task_execution.arn
  task_role_arn            = var.server_task_role_arn
  container_definitions    = <<DEFINITION
[
  {
    "image": "${var.server_image}",
    "cpu": 256,
    "memory": 512,
    "name": "${local.server_container_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.server_container_port},
        "hostPort": ${var.server_container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "SERVER_PORT",
        "value": "${var.server_container_port}"
      },
      {
        "name": "DYNAMO_TABLE",
        "value": "${var.dynamo_table_name}"
      },
      {
        "name": "AWS_REGION",
        "value": "${var.region}"
      },
      {
        "name": "CLIENT_ORIGIN",
        "value": "http://${aws_alb.guestbook.dns_name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.guestbook_server.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "guestbook_client" {
  family                   = "guestbook-client-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.guestbook_task_execution.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.client_image}",
    "cpu": 256,
    "memory": 512,
    "name": "${local.client_container_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.client_container_port},
        "hostPort": ${var.client_container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "REACT_APP_SERVER_URL",
        "value": "http://${aws_alb.guestbook.dns_name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.guestbook_client.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "guestbook_server" {
  name = "/fargate/service/guestbook-server-${var.environment}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "guestbook_client" {
  name = "/fargate/service/guestbook-client-${var.environment}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "guestbook_server" {
  name        = "guestbook_server_${var.environment}"
  description = "allow http access to fargate tasks"
  vpc_id      = var.vpc_id

  depends_on = [aws_alb.guestbook]

  ingress {
    protocol        = "tcp"
    from_port       = var.server_container_port
    to_port         = var.server_container_port
    security_groups = [aws_security_group.guestbook.id] // not sure why ingress rule gets an array of sec groups
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}
