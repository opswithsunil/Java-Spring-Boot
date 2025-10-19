terraform {
  required_version = ">= v1.13.0"
  backend "gcs" {
    bucket = "autovyn-task-terraform"
    prefix = "terraform"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.7.0"
    }
  }
}