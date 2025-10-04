variable "project_name"       { type = string }
variable "platform_arn"       { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "alb_sg_id"          { type = string }
variable "app_sg_id"          { type = string }
variable "app_env_vars"       { 
    type = map(string)
    default = {} 
}
