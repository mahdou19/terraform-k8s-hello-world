output "private_network_id" {
  value = scaleway_vpc_private_network.private_network.id
}

output "nginx_ingress" {
  value = helm_release.nginx_ingress.id
}

output "load_balancer_ip" {
  value = "http://${scaleway_lb_ip.ingress_ip.ip_address}"
}
