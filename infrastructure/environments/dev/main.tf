resource "aws_iam_user" "local_dev_user" {
  name = var.local_user_name
}

resource "aws_iam_access_key" "local_dev_user" {
  user = aws_iam_user.local_dev_user.name
}

locals {
  environment = "dev"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

module "db" {
  source = "../../modules/db"
  providers = {
    aws = aws
  }

  environment = local.environment
  read_capacity = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity
  dev_user_arn = aws_iam_user.local_dev_user.arn
}
