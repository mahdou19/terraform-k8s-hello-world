/*****************************************************
                VPC Private Network
******************************************************/

resource "scaleway_vpc_private_network" "private_network" {
  name = "private-network-${local.name}"
}

/*****************************************************
                Deploy Cluster K8s
******************************************************/

resource "scaleway_k8s_cluster" "cluster" {
  name                        = "cluster-${local.name}"
  version                     = "1.29.1"
  cni                         = "calico"
  private_network_id          = scaleway_vpc_private_network.private_network.id
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "pool" {
  cluster_id = scaleway_k8s_cluster.cluster.id
  name       = "pool-${local.name}"
  node_type  = "DEV1-M"
  size       = 1
}

/*****************************************************
                Deploy Ingress Controller 
******************************************************/

resource "scaleway_lb_ip" "ingress_ip" {}

resource "scaleway_lb" "ingress_lb" {
  name   = "lb-${local.name}"
  ip_ids = [scaleway_lb_ip.ingress_ip.id]
  type   = "LB-S"
}
