variable "project_id" { type = string }
variable "region" { type = string }
variable "name_prefix" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_tier" { type = string }
variable "network" { type = string }
variable "private_ip_subnet" { type = string }

locals {
  instance_name = "${var.name_prefix}-pg"
}

resource "random_password" "dbpass" {
  length  = 20
  special = true
}

resource "google_sql_database_instance" "postgres" {
  project          = var.project_id
  name             = local.instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier              = var.db_tier
    activation_policy = "ALWAYS"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "2000"
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "db_user" {
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  name     = var.db_user
  password = random_password.dbpass.result
}

resource "google_sql_database" "appdb" {
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  name     = var.db_name
}

output "instance_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}
output "private_ip_address" {
  value = google_sql_database_instance.postgres.ip_address[0].ip_address
}
output "db_user" {
  value = google_sql_user.db_user.name
}
output "db_password" {
  value     = random_password.dbpass.result
  sensitive = true
}
