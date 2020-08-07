output "alb_dns_name" {
  value = aws_alb.guestbook.dns_name
  description = "the DNS name of the load balancer"
}
