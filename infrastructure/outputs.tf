output "alb_dns_host" {
  value = "http://${aws_alb.guestbook.dns_name}"
}
