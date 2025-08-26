resource "aws_lb_target_group" "this" {
  name        = var.tg_name
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTPS"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }

  tags = var.tags
}
