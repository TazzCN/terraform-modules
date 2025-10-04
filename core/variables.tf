variable "aws_region" {
    type    = string
    default = "eu-west-2"
}

variable "project_name" { 
    type = string 
    default = "core" 
}

variable "vpc_cidr"        { 
    type = string 
    default = "10.20.0.0/16" 
}

variable "public_subnets"  { 
    type = list(string) 
    default = ["10.20.0.0/24"]
    # default = ["10.20.0.0/24","10.20.1.0/24"] # If we want 2 public subnets in different AZs for Redundancy
}
variable "private_subnets" { 
    type = list(string) 
    default = ["10.20.10.0/24"]
    # default = ["10.20.10.0/24","10.20.11.0/24"] # If we want 2 private subnets in different AZs for Redundancy
}

variable "enable_cognito" { 
    type = bool 
    default = true 
}

variable "cognito_domain_prefix" { 
    type = string 
    default = "tazzcn-auth" 
}
