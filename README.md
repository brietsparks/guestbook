# Guestbook

A simple app with automated infrastructure provisioning, app deployment, and E2E testing.

- Terraform IaC, modularized and multi-environment 
- Golang JSON+HTTP API server
- React webapp client
- Dockerized, horizontally scaled via ECS Fargate 
- DynamoDB
- E2E Testing with [Terratest](https://terratest.gruntwork.io) and [Cypress](https://www.cypress.io/)

Table of contents:
- [Architecture](https://github.com/brietsparks/guestbook#architecture)
- [Dependencies](https://github.com/brietsparks/guestbook#dependencies)
- [Deployment and Tear Down](https://github.com/brietsparks/guestbook#deployment-and-tear-down)
- [Infrastructure E2E Testing](https://github.com/brietsparks/guestbook#infrastructure--e2e-testing)
- [Deploy dev environment infrastructure](https://github.com/brietsparks/guestbook#deploy-dev-environment-infrastructure)
- [Next steps](https://github.com/brietsparks/guestbook#next-steps)
- [LICENSE](https://github.com/brietsparks/guestbook#license)

## Architecture

The frontend and backend applications each run in Docker containers and are horizontally scaled in an ECS Fargate cluster. They sit in private subnets but can be reached through an application load balancer and are able to pull from DockerHub ([server](https://hub.docker.com/repository/docker/brietsparks/guestbook-server) and [client](https://hub.docker.com/repository/docker/brietsparks/guestbook-client)) via a NAT instance. The backend application stores data in a DynamoDB table. All IAM permissions are provided via IAM roles so that no long-lived access keys exist.   

![AWS Architecture Diagram for Guestbook Application](https://raw.githubusercontent.com/brietsparks/guestbook/master/aws-arch-diagram.png "AWS Architecture Diagram for Guestbook Application")

## Dependencies
- an AWS account with an IAM user capable of creating the resources. Currently, I have been using `AdministratorAccess`. Determining the minimum permission scope is on the list of todos (see [Next steps](https://github.com/brietsparks/guestbook#next-steps)).
- a locally configured AWS profile for the above IAM user
- Terraform `~> 0.12.0`
- GNU Make

## Deployment and Tear Down
This section Deploying the infrastructure and applications to AWS requires just a few commands. **Warning: this will create AWS resources that cost money**. 

**Deployment steps**
1. Clone the repo
    ```
    git clone git@github.com:brietsparks/guestbook.git
    ```

2. In the project root, create a Terraform var-file. Run:
    ```
    touch .tfvars
    ```
    and in the file, set your AWS profile:
    ```
    // .tfvars
    profile = <iam-profile>
    ```
    See the [Prod Terraform Inputs](https://github.com/brietsparks/guestbook/blob/master/infrastructure/environments/prod/README.md) for additional optional parameters.
    
3. Next, run:
    ```
    make prod
    ```
    When prompted with the Terraform plan, type `yes` to create the resources. **These resources cost money.**
   
4. After Terraform creates the resources, it will output the load balancer DNS host address:
    ```
    alb_dns_host = http://guestbook-server-123456789.us-west-2.elb.amazonaws.com
    ``` 
    Wait a minute or two for the ECS task containers to start. Then in the browser, navigate to DNS host address to use the app.

5. To tear down the app and its AWS resources, run:
    ```
    make prod-down
    ```
    When prompted with the Terraform plan, type `yes` to destroy the resources.

App demo: a user can view and submit comments for their particular IP address:
![Guestbook Application Demo GIF](https://raw.githubusercontent.com/brietsparks/guestbook/master/demo.gif "Guestbook Application Demo GIF")

## Infrastructure + E2E Testing
On each test run:
1. Terratest provisions the infrastructure
2. Cypress runs E2E tests against the deployed frontend application
3. Terratest deprovisions the infrastructure. 

**Dependencies**
- the [base dependencies](https://github.com/brietsparks/guestbook#dependencies)
- Go `>=1.14`
- NodeJS `>=12.8.1` 
- yarn package manager. If you don't have yarn, then run `npm install` in the /client directory before running the tests.   

**Testing steps**
1. Follow steps 1 and 2 of [the deployment steps](https://github.com/brietsparks/guestbook#deployment-and-tear-down) above.

2. In the project root, run:
   ```
   make test
   ```
   When prompted with the Terraform plan, type `yes` to create the resources.

   
## Deploy dev environment infrastructure
The dev environment creates a DynamoDB table and an IAM user+role that can access the table. Terraform outputs the credentials which the backend app can use for local development.

**Steps:**
1. In the project root, create a Terraform var-file and set the `profile`. See the [Dev Terraform Inputs](https://github.com/brietsparks/guestbook/blob/master/infrastructure/environments/dev/README.md) for additional optional parameters.

2. Run:
   ```
   make dev
   ```

3. After Terraform creates the resources, it will output the IAM config and credentials for accessing the database:

    ```
    Outputs:

    cli_config = 
    [local_dev_user]
    region = us-west-2
    
    [local_dev_user_role]
    role_arn = arn:aws:iam::0123456789012:role/dynamodb_data_access_role_dev
    source_profile = local_dev_user
    
    cli_credentials = 
    [local_dev_user]
    aws_access_key_id = <key>
    aws_secret_access_key = <secret>
    ```
   
4. Paste the config and credential entries into your local shared AWS config and credentials files (in `~/.aws`)

5. You can now run the server locally using the deployed dev database. See the [steps for using the server locally](https://github.com/brietsparks/guestbook/blob/master/server/README.md).

6. To tear down the dev infrastructure, run:
    ```
    make down-down
    ```
    When prompted with the Terraform plan, type `yes` to destroy the resources.

## Next steps
Here are a few things that should be done next:

- CI/CD pipeline
- HTTPS via ELB SSL termination
- VPC endpoints for DynamoDB
- implement VPC without 3rd party module
- minimize permission scope of TF AWS profile 
- vendor-neutral rewrite

## LICENSE
MIT
