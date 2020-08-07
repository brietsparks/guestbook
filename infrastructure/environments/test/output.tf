output "alb_dns_host" {
  description = "the load balancer's DNS host address"
  value       = module.guestbook.alb_dns_host
}
