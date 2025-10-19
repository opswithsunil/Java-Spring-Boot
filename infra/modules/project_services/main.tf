variable "project_id" { type = string }
variable "region" { type = string }

locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "apigateway.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "cloudfunctions.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
