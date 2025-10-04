resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id
  ingress { 
    from_port=80  
    to_port=80  
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
  }
  ingress { 
    from_port=443 
    to_port=443 
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
  }

  # Allow ALB to initiate outbound connections anywhere
  egress  { 
    from_port=0   
    to_port=0   
    protocol="-1"  
    cidr_blocks=["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "app" {
  name   = "${var.project_name}-app-sg"
  vpc_id = var.vpc_id
  # Only ALB can reach app on 80
  ingress { 
    from_port=80 
    to_port=80 
    protocol="tcp" 
    security_groups=[aws_security_group.alb.id] 
    }
  egress  { 
    from_port=0  
    to_port=0  
    protocol="-1"  
    cidr_blocks=["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id
  # Only app can reach DB
  ingress { 
    from_port=5432 
    to_port=5432 
    protocol="tcp" 
    security_groups=[aws_security_group.app.id] 
  }
  egress  { 
    from_port=0    
    to_port=0    
    protocol="-1"  
    cidr_blocks=["0.0.0.0/0"] 
  }
}
