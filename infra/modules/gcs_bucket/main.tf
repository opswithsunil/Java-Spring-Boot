variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "region" { type = string }
variable "env" { type = string }

resource "google_storage_bucket" "bucket" {
  project                     = var.project_id
  name                        = "${var.name_prefix}-${var.env}-uploads"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  versioning {
    enabled = false
  }
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 30
    }
  }
}

output "bucket_name" {
  value = google_storage_bucket.bucket.name
}
