variable "project_id" { type = string }
variable "name" { type = string }

resource "google_pubsub_topic" "topic" {
  name    = var.name
  project = var.project_id
}

resource "google_pubsub_subscription" "subscription" {
  name                 = "${var.name}-sub"
  topic                = google_pubsub_topic.topic.name
  ack_deadline_seconds = 30
  project              = var.project_id
}

output "topic_name" {
  value = google_pubsub_topic.topic.name
}
output "subscription_name" {
  value = google_pubsub_subscription.subscription.name
}
