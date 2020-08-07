//
// required
//
variable "profile" {
  type        = string
  description = "an aws profile to act on behalf of terraform"
}

variable "environment" {
  type = string
  description = "the environment"
}

//
// optional
//
variable "region" {
  type        = string
  description = "an aws region"
  default     = "us-west-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "array of aws availability zones of the provided region"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "server_image" {
  type        = string
  description = "image name of the server app"
  default     = "brietsparks/guestbook-server"
}

variable "client_image" {
  type        = string
  description = "image name of the client app"
  default     = "brietsparks/guestbook-client"
}

variable "server_container_port" {
  type        = string
  description = "the port that the server serves from"
  default     = 80
}

variable "client_container_port" {
  type        = string
  description = "the port that the client serves from"
  default     = 80
}

variable "local_user_name" {
  type = string
  description = "the name of the IAM user for local development"
  default = "local_dev_user"
}

variable "dynamo_read_capacity" {
  type        = string
  description = "the dynamo read throughput"
  default     = 15
}

variable "dynamo_write_capacity" {
  type        = string
  description = "the dynamo write throughput"
  default     = 15
}
