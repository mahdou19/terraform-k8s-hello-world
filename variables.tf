variable "scaleway_access_key" {}
variable "scaleway_secret_key" {}
variable "scaleway_project_id" {}

variable "region" {
  default = "fr-par"
}

variable "zone" {
  default = "fr-par-1"
}

locals {
  name = "mamadou"
}
