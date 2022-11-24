# -------------------------
# Define el provider de AWS
# -------------------------
provider "aws" {
  #region = "us-east-1"
  region = local.region  
}

# --------------------------
# Variables Locales
# --------------------------

locals {
  region = "us-east-1"
  ami = var.ubuntu_ami[local.region]
}

data "aws_subnet" "az_a" {
  #availability_zone = "us-east-1a"
  availability_zone = "${local.region}a"
}

data "aws_subnet" "az_b" {
  #availability_zone = "us-east-1b"
  availability_zone = "${local.region}b"
}

#provider "aws" {
#  shared_config_files      = ["/home/eduardo/.aws/config"]
#  shared_credentials_files = ["/home/eduardo/.aws/credentials"]
#  profile                  = ""
#}

# ---------------------------------------
# Define una instancia EC2 con AMI Ubuntu
# ---------------------------------------
resource "aws_instance" "server_01" {
  #ami = "ami-08c40ec9ead489470"
  #ami = var.ubuntu_ami["us-east-1"]
  ami = local.ami
  #instance_type = "t2.micro"
  instance_type = var.tipo_instancia
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_seguridad.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Mundo Inmundo soy el Server 01" > index.html
              #nohup busybox httpd -f -p 8080 &
              nohup busybox httpd -f -p {var.puerto_server} &
              EOF 
  tags = {
    Name = "server-01"
  }
}

# ---------------------------------------
# Define una instancia EC2 con AMI Ubuntu
# ---------------------------------------
resource "aws_instance" "server_02" {
  #ami = "ami-08c40ec9ead489470"
  #ami = var.ubuntu_ami["us-east-1"]
  ami = local.ami
  #instance_type = "t2.micro"
  instance_type = var.tipo_instancia
  subnet_id = data.aws_subnet.az_b.id
  vpc_security_group_ids = [aws_security_group.mi_grupo_seguridad.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Mundo Inmundo soy el Server 02" > index.html
              #nohup busybox httpd -f -p 8080 &
              nohup busybox httpd -f -p ${var.puerto_server} &
              EOF
  tags = {
    Name = "server-02"
  }
}

resource "aws_security_group" "mi_grupo_seguridad" {
  name = "servidor-8080"

  ingress {
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.sg_lb.id]
    description = "Acceso al puerto 8080 desde el exterior"
    #from_port = 8080
    from_port = var.puerto_server
    #to_port = 8080
    to_port = var.puerto_server
    protocol = "TCP"
  }

}

resource "aws_lb" "lb01" {
  load_balancer_type = "application"
  name = "terraformers-alb"
  security_groups = [aws_security_group.sg_lb.id]
  subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

resource "aws_security_group" "sg_lb" {
  name = "terraform_sg_lb"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    #from_port = 80
    from_port = var.puerto_lb
    #to_port = 80
    to_port = var.puerto_lb
    protocol = "TCP"
  }
  
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 8080 de nuestros servers"
    #from_port = 8080
    from_port = var.puerto_server
    #to_port = 8080
    to_port = var.puerto_server
    protocol = "TCP"
  }

}

data "aws_vpc" "default" {
  default = true
}

resource "aws_lb_target_group" "this" {
  name = "terraformers-alb-target-group"
  #port = 80
  port = var.puerto_lb
  vpc_id = data.aws_vpc.default.id
  protocol = "HTTP"
  
  health_check {
    enabled = true
    matcher = "200"
    path = "/"
    #port = "8080"
    port = var.puerto_server
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "server_01" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id = aws_instance.server_01.id
  #port = 8080
  port = var.puerto_server
}

resource "aws_lb_target_group_attachment" "server_02" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id = aws_instance.server_02.id
  #port = 8080
  port = var.puerto_server
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.lb01.arn
  #port = 80
  port = var.puerto_lb
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type = "forward"
  }
}
