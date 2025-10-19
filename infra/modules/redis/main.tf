variable "project_id" { type = string }
variable "region" { type = string }
variable "name" { type = string }
variable "network" { type = string }
variable "tier" { type = string }
variable "memory_size_gb" { type = number }

resource "google_redis_instance" "redis" {
  provider           = google
  project            = var.project_id
  name               = var.name
  region             = var.region
  tier               = var.tier
  memory_size_gb     = var.memory_size_gb
  authorized_network = var.network
}

output "host" {
  value = google_redis_instance.redis.host
}
output "port" {
  value = google_redis_instance.redis.port
}
