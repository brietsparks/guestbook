//
// required
//
variable "profile" {
  description = "an aws profile to act on behalf of terraform"
}

variable "app_port" {
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

variable "dynamo_read_capacity" {
  default = 4
}

variable "dynamo_write_capacity" {
  default = 4
}
