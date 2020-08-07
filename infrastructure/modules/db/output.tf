output "role_arn" {
  description = "the arn of the role to be assumed when accessing the database"
  value = aws_iam_role.dynamodb_data_access_role.arn
}

output "table_name" {
  description = "the DynamoDB table name"
  value = local.table_name
}
