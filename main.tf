resource "scaleway_vpc_private_network" "private_network" {
  name = "private-network-${local.name}"
}
