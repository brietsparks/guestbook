module "guestbook" {
  source = "../../modules/app"
  environment = "prod"
  profile = var.profile
  region = var.region
  availability_zones = var.availability_zones
  server_image = var.server_image
  client_image = var.client_image
  server_container_port = var.server_container_port
  client_container_port = var.client_container_port
  dynamo_read_capacity = var.dynamo_read_capacity
  dynamo_write_capacity = var.dynamo_write_capacity
}
