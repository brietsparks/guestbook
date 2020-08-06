output "alb_dns_host" {
  description = "the load balancer's DNS host address"
  value       = "http://${aws_alb.guestbook.dns_name}"
}

output "local_dev_user_access_key" {
  description = "the access key of the IAM user to use for local development"
  value = aws_iam_access_key.local_dev_user.id
}

output "local_dev_user_access_secret" {
  description = "the access secret of the IAM user to use for local development"
  value = aws_iam_access_key.local_dev_user.secret
}

output "dynamodb_data_access_role_arn" {
  description = "the arn of role that allows access to dynamodb"
  value = aws_iam_role.dynamodb_data_access_role.arn
}
