/*
A local user that can read and write to DynamoDB
*/
resource "aws_iam_user" "local_dev_user" {
  name = var.local_user_name
}

resource "aws_iam_access_key" "local_dev_user" {
  user = aws_iam_user.local_dev_user.name
}

/*
Allow an ECS task to execute what it needs. See:
*/
// the role
resource "aws_iam_role" "guestbook_task_execution" {
  name               = "guestbook_task_execution"
  assume_role_policy = data.aws_iam_policy_document.guestbook_task_execution.json
}
// who can assume the role
data "aws_iam_policy_document" "guestbook_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
// what the role can do. See:
// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy_attachment" "guestbook_task_execution" {
  role       = aws_iam_role.guestbook_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


/*
Allow an ECS task and the local dev user to read and write to DynamoDB
*/
// the role
resource "aws_iam_role" "dynamodb_data_access_role" {
  name               = "dynamodb_data_access_role"
  description        = "Provides write and read access to DynamoDB data"
  assume_role_policy = data.aws_iam_policy_document.dynamo_db_data_role_assumption.json
}
// who can assume the role
data "aws_iam_policy_document" "dynamo_db_data_role_assumption" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = [aws_iam_user.local_dev_user.arn]
      type = "AWS"
    }
  }
}
// what the role can do. See:
// https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Operations_Amazon_DynamoDB.html
resource "aws_iam_role_policy" "dynamodb_data_access" {
  name   = "dynamodb_data_access"
  role   = aws_iam_role.dynamodb_data_access_role.id
  policy = data.aws_iam_policy_document.dynamodb_data_access.json
}
data "aws_iam_policy_document" "dynamodb_data_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ListGlobalTables",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:ListTables",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable"
    ]
    resources = [
      aws_dynamodb_table.guestbook_server.arn
    ]
  }
}
