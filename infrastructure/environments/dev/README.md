## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dynamo\_read\_capacity | the dynamo read throughput | `string` | `15` | no |
| dynamo\_write\_capacity | the dynamo write throughput | `string` | `15` | no |
| local\_user\_name | the name of the IAM user for local development | `string` | `"local_dev_user"` | no |
| profile | an aws profile to act on behalf of terraform | `string` | n/a | yes |
| region | an aws region | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cli\_config | the config to set locally for the user and role |
| cli\_credentials | the credentials to set locally for the user |
| table\_name | the DynamoDB table name |

