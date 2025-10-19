variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "region" { type = string }
variable "image" { type = string }
variable "service_account" { type = string }
variable "env_vars" {
  type    = map(string)
  default = {}
}


resource "google_service_account" "cr_sa" {
  project      = var.project_id
  account_id   = replace(var.service_account, "@${var.project_id}.iam.gserviceaccount.com", "")
  display_name = "${var.name_prefix}-cloudrun-sa"
}

resource "google_cloud_run_service" "service" {
  provider = google-beta
  name     = "${var.name_prefix}-worker"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cr_sa.email
      containers {
        image = var.image

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/ingress" = "all"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}


# Allow unauthenticated? keep disabled by default
resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.cr_sa.email}"
}
output "cloudrun_url" {
  value = google_cloud_run_service.service.status[0].url
}
