provider "aws" {
  profile = var.profile
  region  = var.region
}

locals {
  server_container_name = "guestbook_server"
  client_container_name = "guestbook_client"
  dynamo_table_name     = "guestbook"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "guestbook"
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "nat" {
  source                      = "int128/nat-instance/aws"
  name                        = "guestbook"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  use_spot_instance           = true
}

//
// applications
//
resource "aws_ecs_cluster" "guestbook" {
  name = "guestbook"
}

resource "aws_ecs_service" "guestbook_server" {
  name            = "guestbook_server"
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
    subnets         = module.vpc.private_subnets
  }
}

resource "aws_ecs_service" "guestbook_client" {
  name            = "guestbook_client"
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
    subnets         = module.vpc.private_subnets
  }
}

resource "aws_ecs_task_definition" "guestbook_server" {
  family                   = "guestbook-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.guestbook_task_execution.arn
  task_role_arn            = aws_iam_role.dynamodb_data_access_role.arn
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
        "value": "${local.dynamo_table_name}"
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
}

resource "aws_ecs_task_definition" "guestbook_client" {
  family                   = "guestbook-client"
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
}

resource "aws_cloudwatch_log_group" "guestbook_server" {
  name = "/fargate/service/guestbook-server"
}

resource "aws_cloudwatch_log_group" "guestbook_client" {
  name = "/fargate/service/guestbook-client"
}

resource "aws_security_group" "guestbook_server" {
  name        = "guestbook_server"
  description = "allow http access to fargate tasks"
  vpc_id      = module.vpc.vpc_id

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
}

//
// load balancer
//
resource "aws_alb" "guestbook" {
  name               = "guestbook-server"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.guestbook.id]
}

resource "aws_alb_listener" "guestbook" {
  load_balancer_arn = aws_alb.guestbook.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.guestbook_client.id
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "guestbook_server" {
  listener_arn = aws_alb_listener.guestbook.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.guestbook_server.arn
  }

  condition {
    path_pattern {
      values = ["/items"]
    }
  }
}

resource "aws_alb_target_group" "guestbook_server" {
  name        = "guestbook-server"
  port        = var.server_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.guestbook]
}

resource "aws_alb_target_group" "guestbook_client" {
  name        = "guestbook-client"
  port        = var.client_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.guestbook]
}

resource "aws_security_group" "guestbook" {
  name        = "guestbook"
  description = "controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//
// database
//
resource "aws_dynamodb_table" "guestbook_server" {
  name           = local.dynamo_table_name
  read_capacity  = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity
  hash_key       = "ip"
  range_key      = "ts"

  attribute {
    name = "ip"
    type = "S"
  }

  attribute {
    name = "ts"
    type = "N"
  }

  tags = {
    Name = local.dynamo_table_name
    //Environment = "dev"
  }
}

