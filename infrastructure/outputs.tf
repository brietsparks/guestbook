output "alb_dns_host" {
  description = "the load balancer's DNS host address"
  value = "http://${aws_alb.guestbook.dns_name}"
}
