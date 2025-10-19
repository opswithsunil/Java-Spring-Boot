output "vpc_name" {
  value = module.vpc.vpc_name
}

output "gke_name" {
  value = module.gke.cluster_name
}

output "cloudsql_instance" {
  value = module.cloudsql.instance_connection_name
}

output "artifact_repo" {
  value = module.artifact.repo_location
}

output "pubsub_topic" {
  value = module.pubsub.topic_name
}

output "gcs_bucket" {
  value = module.gcs.bucket_name
}

output "redis_host" {
  value = module.redis.host
}
