/*
Allow an ECS task to execute what it needs. See:
*/
// the role
resource "aws_iam_role" "guestbook_task_execution" {
  name               = "guestbook_task_execution_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.guestbook_task_execution.json

  tags = {
    Environment = var.environment
  }
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
