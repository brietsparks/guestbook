# Guestbook

A simple app with automated infrastructure provisioning, app deployment, and E2E testing.

- Terraform infrastructure deployment to AWS
- Golang JSON+HTTP API server
- React webapp client
- Dockerized, horizontally scaled via ECS Fargate 
- DynamoDB
- E2E Testing with [Terratest](https://terratest.gruntwork.io) and [Cypress](https://www.cypress.io/)

Table of contents:
- [Architecture](https://github.com/brietsparks/guestbook#architecture)
- [Setup](https://github.com/brietsparks/guestbook#setup)
- [E2E Testing](https://github.com/brietsparks/guestbook#infrastructure--e2e-testing)
- [Terraform Inputs](https://github.com/brietsparks/guestbook#terraform-inputs)
- [Terraform Outputs](https://github.com/brietsparks/guestbook#terraform-outputs)
- [Next steps](https://github.com/brietsparks/guestbook#next-steps)
- [LICENSE](https://github.com/brietsparks/guestbook#license)

## Architecture

The frontend and backend applications each run in Docker containers and are horizontally scaled in an ECS Fargate cluster. They sit in private subnets but can be reached through an application load balancer and are able to pull from DockerHub ([server](https://hub.docker.com/repository/docker/brietsparks/guestbook-server) and [client](https://hub.docker.com/repository/docker/brietsparks/guestbook-client)) via a NAT instance. The backend application stores data in a DynamoDB table. All IAM permissions are provided via IAM roles so that no long-lived access keys exist.   

![AWS Architecture Diagram for Guestbook Application](https://raw.githubusercontent.com/brietsparks/guestbook/master/aws-arch-diagram.png "AWS Architecture Diagram for Guestbook Application")

## Setup
Deploying the infrastructure and applications to AWS requires just a few commands. **Warning: this will create AWS resources that cost money**. After deploying and testing you can run `terraform destroy` (see the steps below) to destroy the resources. 

**Dependencies**
- an AWS account with an IAM user capable of creating the resources. Currently, I have been using `AdministratorAccess`. Minimizing the required permission scope is on the list of todos (see "Next steps" section below).
- a locally configured AWS profile
- Terraform `~> 0.12.0`

**Steps**
1. clone the repo
    ```
    git clone git@github.com:brietsparks/guestbook.git
    ```

2. navigate to the `/infrastructure` directory,
    ```
    cd guestbook/infrastructure
    ``` 
    create a Terrfaform var-file,
    ```
    touch .tfvars
    ```
    and set your AWS profile in the file.
    ```
    // .tfvars
    profile = "my-iam-profile"
    ```
    See the "Terraform variables" section below for customizability.
    
3. Initialize Terraform
    ```
    terraform init
    ``` 
    
4. Run Terraform in the infrastructure directory:
    ```
    terraform apply -var-file=.tfvars
    ```
    You will be prompted with a Terraform plan. Type `yes` to create the resources.
   
5. After creating the resources, Terraform will output the load balancer's DNS host address:
    ```
    alb_dns_host = http://guestbook-server-123456789.us-west-2.elb.amazonaws.com
    ``` 
    In you browser, navigate to this url to use the app.

6. If you want to tear down the app and its AWS resources, run:
    ```
    terraform destroy -var-file=.tfvars
    ```
    You will be prompted with a Terraform plan. Type `yes` to destroy the resources.
    
A user can see and submit comments for their particular IP address:
![Guestbook Application Demo GIF](https://raw.githubusercontent.com/brietsparks/guestbook/master/demo.gif "Guestbook Application Demo GIF")

## Infrastructure + E2E Testing
On each test run, Terratest provisions the infrastructure. Then Cypress runs E2E tests against the deployed frontend application. Afterwards Terratest deprovisions the infrastructure. 

1. Follow steps 1-3 in [the setup steps](https://github.com/brietsparks/guestbook#setup) above.
2. In the infrastructure directory, run:
    ```
    go test -v -run TestInfrastructure -timeout 15m
    ```

## Terraform Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zones | array of aws availability zones of the provided region | `list` | <pre>[<br>  "us-west-2a",<br>  "us-west-2b"<br>]</pre> | no |
| client\_container\_port | the port that the client serves from | `string` | `80` | no |
| client\_image | image name of the client app | `string` | `"brietsparks/guestbook-client"` | no |
| dynamo\_read\_capacity | the dynamo read throughput | `string` | `15` | no |
| dynamo\_write\_capacity | the dynamo write throughput | `string` | `15` | no |
| profile | an aws profile to act on behalf of terraform | `string` | n/a | yes |
| region | an aws region | `string` | `"us-west-2"` | no |
| server\_container\_port | the port that the server serves from | `string` | `80` | no |
| server\_image | image name of the server app | `string` | `"brietsparks/guestbook-server"` | no |

## Terraform Outputs

| Name | Description |
|------|-------------|
| alb\_dns\_host | the load balancer's DNS host address |


## Next steps
Here are a few things that should be done next:

- separate dev and prod infrastructure environments
- CI/CD pipeline
- HTTPS via ELB SSL termination
- VPC endpoints for DynamoDB
- implement VPC without 3rd party module
- modularize infrastructure code
- minimize permission scope of TF AWS profile 
- vendor-neutral rewrite

## LICENSE
MIT
