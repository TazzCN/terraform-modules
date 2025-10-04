variable "project_name"       { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_sg_id"           { type = string }
variable "db_password"        { 
    type = string
    sensitive = true 
}

# simple defaults you can override later
variable "engine"             { 
    type = string 
    default = "postgres" 
}
variable "engine_version"     { 
    type = string
    default = "14" 
}
variable "instance_class"     { 
    type = string
    default = "db.t4g.micro" 
}
variable "db_name"            { 
    type = string 
    default = "appdb" 
}
variable "username"           { 
    type = string 
    default = "appuser" 
}
