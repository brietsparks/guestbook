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
| client\_container\_port | the port that the client serves from | `string` | n/a | yes |
| client\_image | image name of the client app | `string` | n/a | yes |
| dynamo\_table\_name | the DynamoDB table that the server talks to | `string` | n/a | yes |
| environment | the environment | `string` | n/a | yes |
| private\_subnets | a list of cidr ranges of the private subnets to run the ECS tasks in | `list(string)` | n/a | yes |
| public\_subnets | a list of cidr ranges of the public subnets for the load balancer | `list(string)` | n/a | yes |
| region | an aws region | `string` | n/a | yes |
| server\_container\_port | the port that the server serves from | `string` | n/a | yes |
| server\_image | image name of the server app | `string` | n/a | yes |
| server\_task\_role\_arn | the role arn for the server ECS task | `string` | n/a | yes |
| vpc\_id | the id of the vpc to run the ECS cluster in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb\_dns\_name | the DNS name of the load balancer |

