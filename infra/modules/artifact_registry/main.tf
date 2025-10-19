variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "region" { type = string }

resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  project       = var.project_id
  location      = var.region
  repository_id = "${var.name_prefix}-docker"
  format        = "DOCKER"
  description   = "Docker images for ${var.name_prefix}"
  mode          = "STANDARD_REPOSITORY"
}

output "repo_location" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}
