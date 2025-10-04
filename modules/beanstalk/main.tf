resource "aws_iam_role" "eb_service" {
  name = "${var.project_name}-eb-service"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{Effect="Allow", Principal={Service="elasticbeanstalk.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy_attachment" "eb_service" {
  role       = aws_iam_role.eb_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role" "eb_instance" {
  name = "${var.project_name}-eb-ec2"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{Effect="Allow", Principal={Service="ec2.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy_attachment" "eb_instance" {
  role       = aws_iam_role.eb_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_instance_profile" "profile" {
  name = "${var.project_name}-eb-instance-profile"
  role = aws_iam_role.eb_instance.name
}

resource "aws_elastic_beanstalk_application" "app" { name = "${var.project_name}-app" }

resource "aws_elastic_beanstalk_environment" "env" {
  name         = "${var.project_name}-env"
  application  = aws_elastic_beanstalk_application.app.name
  platform_arn = var.platform_arn
  tier         = "WebServer"

  setting { 
    namespace="aws:elasticbeanstalk:environment"
    name="ServiceRole"
    value=aws_iam_role.eb_service.name 
  }
  setting { 
    namespace="aws:autoscaling:launchconfiguration"
    name="IamInstanceProfile"
    value=aws_iam_instance_profile.profile.name 
  }

  # VPC/Subnets/SG
  setting { 
    namespace="aws:ec2:vpc"
    name="VPCId"
    value=var.vpc_id 
  }
  setting { 
    namespace="aws:ec2:vpc"
    name="Subnets"
    value=join(",", var.private_subnet_ids) 
  }
  setting { 
    namespace="aws:ec2:vpc"
    name="ELBSubnets"
    value=join(",", var.public_subnet_ids) 
  }
  setting { 
    namespace="aws:autoscaling:launchconfiguration"
    name="SecurityGroups"
    value=var.app_sg_id 
  }
  setting { 
    namespace="aws:elb:loadbalancer"
    name="SecurityGroups"
    value=var.alb_sg_id 
  }

  dynamic "setting" {
    for_each = var.app_env_vars
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }
}
