//
// required
//
variable "profile" {
  type        = string
  description = "an aws profile to act on behalf of terraform"
}

//
// optional
//
variable "region" {
  type        = string
  description = "an aws region"
  default     = "us-west-2"
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
