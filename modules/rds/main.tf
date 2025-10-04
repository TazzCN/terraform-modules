variable "project_name"       { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_sg_id"           { type = string }
variable "db_password"        { 
  type = string
  sensitive = true 
}

variable "engine"         { 
  type = string 
  default = "postgres" 
}
variable "engine_version" { 
  type = string
  default = "14" 
}
variable "instance_class" { 
  type = string
  default = "db.t4g.micro" 
}
variable "db_name"        { 
  type = string
  default = "appdb"
}
variable "username"       { 
  type = string 
  default = "appuser" 
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "db" {
  identifier             = "${var.project_name}-db"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.db_password
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_encrypted      = true
  publicly_accessible    = false
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true
}
output "endpoint" { value = aws_db_instance.db.address }
