provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "guestbook_${var.environment}"
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Environment = var.environment
  }
}

module "nat" {
  source                      = "int128/nat-instance/aws"
  name                        = "guestbook_${var.environment}"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  use_spot_instance           = true

  tags = {
    Environment = var.environment
  }
}


module "db" {
  source = "../../modules/db"
  providers = {
    aws = aws
  }

  environment = var.environment
  read_capacity = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity
}

module "ecs" {
  source = "../../modules/ecs"
  providers = {
    aws = aws
  }
  environment = var.environment

  client_container_port = var.client_container_port
  client_image = var.client_image
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  region = var.region
  server_container_port = var.server_container_port
  server_image = var.server_image
  server_task_role_arn = module.db.role_arn
  vpc_id = module.vpc.vpc_id
  dynamo_table_name = module.db.table_name
}

