//
// required
//
variable "profile" {
  type = "string"
  description = "an aws profile to act on behalf of terraform"
}

// https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-create-personal-token-CLI.html
variable "github_oauth_token" {
  type = "string"
  description = " the GitHub authentication token that allows CodePipeline to perform operations on your GitHub repository"
}

//variable "github_personal_access_token" {
//  type = string
//  description = "a github personal access token"
//}

//
// optional
//
variable "region" {
  type = "string"
  description = "an aws region"
  default = "us-west-2"
}

variable "availability_zones" {
  type = "list"
  description = "array of aws availability zones of the provided region"
  default = ["us-west-2a", "us-west-2b"]
}

variable "server_image" {
  type = "string"
  description = "image name of the server app"
  default = "brietsparks/guestbook-server"
}

variable "client_image" {
  type = "string"
  description = "image name of the client app"
  default = "brietsparks/guestbook-client"
}

variable "server_container_port" {
  type = "string"
  description = "the port that the server serves from"
  default = 80
}

variable "client_container_port" {
  type = "string"
  description = "the port that the client serves from"
  default = 80
}

variable "dynamo_read_capacity" {
  type = "string"
  description = "the dynamo read throughput"
  default = 15
}

variable "dynamo_write_capacity" {
  type = "string"
  description = "the dynamo write throughput"
  default = 15
}

variable "github_repo_owner" {
  default = "brietsparks"
}

variable "github_repo_name" {
  default = "guestbook"
}

variable "server_buildspec_path" {
  type = string
  description = "path to the server's buildspec file"
  default = "server/ci/buildspec.yml"
}
