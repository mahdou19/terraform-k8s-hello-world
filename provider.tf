
terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  region     = var.region
  zone       = var.zone
  access_key = var.scaleway_access_key
  secret_key = var.scaleway_secret_key
  project_id = var.scaleway_project_id
}


data "scaleway_k8s_cluster" "cluster_info" {
  cluster_id = scaleway_k8s_cluster.cluster.id
}

provider "helm" {
  kubernetes {
    host                   = data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["host"]
    token                  = data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["token"]
    cluster_ca_certificate = base64decode(data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["cluster_ca_certificate"])
  }
}

provider "kubernetes" {
  host                   = data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["host"]
  token                  = data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["token"]
  cluster_ca_certificate = base64decode(data.scaleway_k8s_cluster.cluster_info.kubeconfig[0]["cluster_ca_certificate"])
}

