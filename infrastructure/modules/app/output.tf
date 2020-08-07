output "alb_dns_host" {
  description = "the load balancer's DNS host address"
  value       = "http://${module.ecs.alb_dns_name}"
}
