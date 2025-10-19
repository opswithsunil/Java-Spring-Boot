variable "project_id" { type = string }
variable "name_prefix" { type = string }
#variable "secrets" { type = map(string) default = {} }
variable "secrets" {
  type    = map(string)
  default = {}
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  project   = var.project_id
  secret_id = "${var.name_prefix}-${each.key}"

  replication {
    auto {}
  }
}


resource "google_secret_manager_secret_version" "secret_version" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
}
