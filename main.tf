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

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.6"

  values = [
    <<EOF
controller:
  ingressClass: "nginx"
  service:
    externalIPs:
      - ${scaleway_lb_ip.ingress_ip.ip_address}
EOF
  ]

  create_namespace = true
}

/*****************************************************
                Deploy Contener Hello-world 
******************************************************/


resource "kubernetes_config_map" "hello_world_html" {
  metadata {
    name = "hello-world-html"
  }

  data = {
    "index.html" = "<html><body><h1>Hello world</h1></body></html>"
  }
}

resource "kubernetes_pod" "hello_world" {
  metadata {
    name = "hello-world"
    labels = {
      app = "MyApp"
    }
  }

  spec {
    container {
      image = "httpd:2.4"
      name  = "hello-world"

      volume_mount {
        mount_path = "/usr/local/apache2/htdocs"
        name       = "html-volume"
      }
    }

    volume {
      name = "html-volume"

      config_map {
        name = kubernetes_config_map.hello_world_html.metadata[0].name
      }
    }
  }
}

resource "kubernetes_service" "hello_world_service" {
  metadata {
    name = "hello-world-service"
    annotations = {
      "service.beta.kubernetes.io/scw-loadbalancer-id" = scaleway_lb.ingress_lb.id
    }
  }

  spec {
    selector = {
      app = "MyApp"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

