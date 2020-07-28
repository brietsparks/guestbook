//
// required
//
variable "profile" {
  description = "an aws profile to act on behalf of terraform"
}

//
// optional
//
variable "region" {
  description = "an aws region"
  default = "us-west-2"
}

variable "availability_zones" {
  description = "array of aws availability zones of the provided region"
  default = ["us-west-2a", "us-west-2b"]
}

variable "server_image" {
  description = "image name of the server app"
  default = "brietsparks/guestbook-server"
}

variable "client_image" {
  description = "image name of the client app"
  default = "brietsparks/guestbook-client"
}

variable "server_port" {
  description = "the port that the server serves from"
  default = 80
}

variable "client_port" {
  description = "the port that the client serves from"
  default = 80
}

variable "dynamo_read_capacity" {
  default = 15
}

variable "dynamo_write_capacity" {
  default = 15
}
