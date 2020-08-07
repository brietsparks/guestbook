resource "aws_alb" "guestbook" {
  name               = "guestbook-server-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.guestbook.id]

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb_listener" "guestbook" {
  load_balancer_arn = aws_alb.guestbook.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.guestbook_client.id
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "guestbook_server" {
  listener_arn = aws_alb_listener.guestbook.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.guestbook_server.arn
  }

  condition {
    path_pattern {
      values = ["/items"]
    }
  }
}

resource "aws_alb_target_group" "guestbook_server" {
  name        = "guestbook-server-${var.environment}"
  port        = var.server_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.guestbook]

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "guestbook_client" {
  name        = "guestbook-client-${var.environment}"
  port        = var.client_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.guestbook]

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "guestbook" {
  name        = "guestbook-${var.environment}"
  description = "controls access to the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}
