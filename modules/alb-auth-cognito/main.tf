variable "project_name"     { type = string }
variable "eb_env_name"      { type = string }
variable "user_pool_arn"    { type = string }
variable "user_pool_client" { type = string }
variable "user_pool_domain" { type = string }

# Look up EB's ALB by tags
data "aws_lb" "eb_alb" {
  tags = {
    "elasticbeanstalk:environment-name" = var.eb_env_name
  }
}

# Use the HTTPS listener if present; otherwise 80
data "aws_lb_listeners" "listeners" {
  load_balancer_arn = data.aws_lb.eb_alb.arn
}

# Pick first HTTPS listener, else first listener
locals {
  https_listener = try(one([for l in data.aws_lb_listeners.listeners.listeners : l if l.port == 443]).arn, null)
  listener_arn   = coalesce(local.https_listener, data.aws_lb_listeners.listeners.listeners[0].arn)
}

# We need the default target group to forward to after auth
data "aws_lb_listener" "chosen" {
  arn = local.listener_arn
}

# Add a high-priority rule requiring Cognito auth
resource "aws_lb_listener_rule" "auth" {
  listener_arn = local.listener_arn
  priority     = 10

  action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = var.user_pool_arn
      user_pool_client_id = var.user_pool_client
      user_pool_domain    = var.user_pool_domain
      on_unauthenticated_request = "authenticate"
      scope = "openid"
      session_cookie_name = "${var.project_name}-alb-auth"
    }
  }

  # Forward to the existing default target group after successful auth
  action {
    type             = "forward"
    target_group_arn = data.aws_lb_listener.chosen.default_action[0].forward[0].target_group[0].arn
  }

  condition { 
    path_pattern { 
      values = ["/*"] 
      } 
    }
}
