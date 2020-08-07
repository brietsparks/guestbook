output "table_name" {
  description = "the DynamoDB table name"
  value = module.db.table_name
}

output "cli_config" {
  description = "the config to set locally for the user and role"
  value = <<EOF

[${var.local_user_name}]
region = ${var.region}

[${var.local_user_name}_role]
role_arn = ${module.db.role_arn}
source_profile = ${var.local_user_name}
EOF
}

output "cli_credentials" {
  description = "the credentials to set locally for the user"
  value = <<EOF

[${var.local_user_name}]
aws_access_key_id = ${aws_iam_access_key.local_dev_user.id}
aws_secret_access_key = ${aws_iam_access_key.local_dev_user.secret}
EOF
}
