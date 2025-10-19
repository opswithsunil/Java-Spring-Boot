variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "env" { type = string }

# Service account for CI to deploy with OIDC / Workload Identity recommended
resource "google_service_account" "ci_sa" {
  account_id   = "${var.name_prefix}-${var.env}-ci"
  project      = var.project_id
  display_name = "CI service account"
}

resource "google_service_account" "worker_sa" {
  account_id   = "${var.name_prefix}-${var.env}-worker-sa"
  project      = var.project_id
  display_name = "Worker service account"
}

# minimal roles for Cloud Run worker: pubsub.subscriber, storage.objectViewer, cloudsql.client
resource "google_project_iam_member" "worker_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.worker_sa.email}"
}

resource "google_project_iam_member" "worker_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.worker_sa.email}"
}

resource "google_project_iam_member" "worker_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.worker_sa.email}"
}

output "ci_service_account" {
  value = google_service_account.ci_sa.email
}

output "worker_service_account" {
  value = google_service_account.worker_sa.email
}
