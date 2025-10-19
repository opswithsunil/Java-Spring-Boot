variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "env" { type = string }

resource "google_container_cluster" "autopilot" {
  name     = "${var.name_prefix}-${var.env}-gke"
  project  = var.project_id
  location = var.region
  enable_autopilot = true
  deletion_protection = false
  
  network          = var.network
  subnetwork       = var.subnetwork

  release_channel {
    channel = "STABLE"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {}

  addons_config {
    http_load_balancing { disabled = false }
    horizontal_pod_autoscaling { disabled = false }
  }
}

# create a k8s service account mapping example (to be used in k8s manifests)
resource "google_service_account" "gke_sa" {
  account_id   = "${var.name_prefix}-${var.env}-gke-sa"
  project      = var.project_id
  display_name = "GKE workload SA for ${var.env}"
}

output "cluster_name" {
  value = google_container_cluster.autopilot.name
}
output "endpoint" {
  value = google_container_cluster.autopilot.endpoint
}
