variable "puerto_server" {
  description = "Puerto de la instancia EC2"
  type = number
  default = 8080
}

variable "puerto_lb" {
  description = "Puerto para el Load Balancer"
  type = number
  default = 80
}

variable "tipo_instancia" {
  description = "Tipo de las instancias EC2"
  type = string
  default = "t2.micro"
}

variable "ubuntu_ami" {
  description = "AMI por Region"
  type = map(string)

  default = {
    us-east-1 = "ami-08c40ec9ead489470" # Ubuntu ubicado en Norte de Virginia
    us-west-2 = "ami-0c09c7eb16d3e8e70" # Ubuntu ubicado en Oregon
  } 

}

