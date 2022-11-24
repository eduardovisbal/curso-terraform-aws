output "dns_publico_server_01" {
  description = "DNS Publica server 01"
  #value = "http://${aws_instance.server_01.public_dns}:8080"
  value = "http://${aws_instance.server_01.public_dns}:${var.puerto_server}"
}

output "dns_publico_server_02" {
  description = "DNS Publica server 02"
  #value = "http://${aws_instance.server_02.public_dns}:8080"
  value = "http://${aws_instance.server_02.public_dns}:${var.puerto_server}"
}

output "dns_load_balancer" {
  description = "DNS publica del Load Balancer"
  #value = "http://${aws_lb.lb01.dns_name}"
  value = "http://${aws_lb.lb01.dns_name}:${var.puerto_lb}"
}

#output "ipv4_servidor" {
#  description = "IPv4 de nuestro servidor"
#  value       = aws_instance.primer_server.public_ip
#}

