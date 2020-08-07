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
| dev\_user\_arn | the arn of the IAM user for local development | `string` | `""` | no |
| environment | the environment | `string` | n/a | yes |
| read\_capacity | the dynamo read throughput | `string` | n/a | yes |
| write\_capacity | the dynamo write throughput | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | the arn of the role to be assumed when accessing the database |
| table\_name | the DynamoDB table name |

