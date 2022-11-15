# Main ALB resource

resource "aws_alb" "alb" {
  name            = local.alb_name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.alb_sg.id]
  tags            = var.tags
}

resource "aws_security_group" "alb_sg" {
  name        = "${local.alb_name}-sg"
  description = "Controls access to ${local.alb_name}"
  vpc_id      = var.vpc_id

  # http to https access from www by default
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_ips
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_ips
  }

  # Allow any outgoing
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_alb_target_group" "tg" {
  name        = "${local.alb_name}-tg"
  target_type = "ip" # this would be configurable in a production scenario to other types
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  tags        = var.tags
  depends_on  = [aws_alb.alb] # Make sure we create the ALB first

  lifecycle {
    create_before_destroy = true
  }

}

# HTTPS and HTTP listeners

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
  depends_on = [
    aws_alb_target_group.tg
  ]
}

resource "aws_alb_listener" "http_to_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      port        = aws_alb_listener.https.port
      protocol    = aws_alb_listener.https.protocol
    }
  }
}
