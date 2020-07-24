provider "aws" {
  profile = var.profile
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "guestbook"
  cidr                 = "10.0.0.0/16"

  azs                  = var.availability_zones
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.101.0/24" , "10.0.102.0/24"]
}

module "nat" {
  source = "int128/nat-instance/aws"
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

resource "aws_ecs_service" "guestbook_api" {
  name            = "guestbook_api"
  cluster         = aws_ecs_cluster.guestbook.id
  task_definition = aws_ecs_task_definition.guestbook_api.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.guestbook_api.arn
    container_name   = "guestbook" // note: must be same as the task definition's name
    container_port   = var.app_port
  }
  network_configuration {
    security_groups = [aws_security_group.guestbook_api.id]
    subnets          = module.vpc.private_subnets
  }
}

resource "aws_ecs_task_definition" "guestbook_api" {
  family                   = "guestbook"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.guestbook_task_execution.arn
  task_role_arn            = aws_iam_role.dynamodb_data_access_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "image": "brietsparks/guestbook",
    "cpu": 256,
    "memory": 512,
    "name": "guestbook",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "SERVER_PORT",
        "value": "80"
      },
      {
        "name": "DYNAMO_TABLE",
        "value": "guestbook"
      },
      {
        "name": "AWS_REGION",
        "value": "us-west-2"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/guestbook",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/guestbook"
}

resource "aws_iam_role" "guestbook_task_execution" {
  name               = "guestbook_task_execution"
  assume_role_policy = data.aws_iam_policy_document.guestbook_task_execution.json
}

data "aws_iam_policy_document" "guestbook_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "guestbook_task_execution" {
  role       = aws_iam_role.guestbook_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "guestbook_api" {
  name = "guestbook_api"
  description = "allow http access to fargate tasks"
  vpc_id = module.vpc.vpc_id

  depends_on = [aws_alb.guestbook_api]

  ingress {
    protocol = "tcp"
    from_port = var.app_port
    to_port = var.app_port
    security_groups = [aws_security_group.guestbook_api_alb.id]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//
// load balancer
//
resource "aws_alb" "guestbook_api" {
  name               = "guestbook-api"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups = [aws_security_group.guestbook_api_alb.id]
}

resource "aws_alb_target_group" "guestbook_api" {
  name = "guestbook-api"
  port        = 80 // todo: does var.app_port work?
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on = [aws_alb.guestbook_api]
}

resource "aws_alb_listener" "guestbook_api" {
  load_balancer_arn = aws_alb.guestbook_api.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.guestbook_api.id
    type             = "forward"
  }
}


resource "aws_security_group" "guestbook_api_alb" {
  name        = "guestbook_api_alb"
  description = "controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//resource "aws_eip" "guestbook" {
//  vpc = true
//}
//resource "aws_eip_association" "guestbook" {
//  instance_id   = aws_alb.guestbook_api.id
//  allocation_id = aws_eip.guestbook_api.id
//}


//
// database
//
resource "aws_dynamodb_table" "guestbook_api" {
  name           = "guestbook"
  read_capacity  = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "guestbook"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "dynamodb_data_access" {
  name = "DynamoDBDataAccess"
  description = "Provides write and read access to DynamoDB data"
  policy = file("definitions/policy_DynamoDBDataAccess.json")
}

resource "aws_iam_role_policy_attachment" "dynamodb_data_access" {
  policy_arn = aws_iam_policy.dynamodb_data_access.arn
  role = aws_iam_role.dynamodb_data_access_role.name
}

resource "aws_iam_role" "dynamodb_data_access_role" {
  name = "DynamoDBDataAccessRole"
  description = "Provides write and read access to DynamoDB data"
  assume_role_policy = file("definitions/policy_DynamoDBDataRoleAssumption.json")
}
