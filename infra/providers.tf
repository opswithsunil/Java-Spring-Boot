provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {
  host                   = var.create_gke ? "https://${module.gke[0].endpoint}" : ""
  token                  = var.create_gke ? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = var.create_gke ? base64decode(module.gke[0].cluster_ca_certificate) : ""
}

provider "helm" {
    kubernetes ={
    host                   = var.create_gke ? "https://${module.gke[0].endpoint}" : ""
    token                  = var.create_gke ? data.google_client_config.default.access_token : ""
    cluster_ca_certificate = var.create_gke ? base64decode(module.gke[0].cluster_ca_certificate) : ""
  }
}
