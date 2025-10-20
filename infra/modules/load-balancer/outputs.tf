output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "url_map_id" {
  description = "The ID of the URL map used by the load balancer"
  value       = google_compute_url_map.url_map.id
}

output "https_proxy_id" {
  description = "The ID of the HTTPS proxy used by the load balancer"
  value       = google_compute_target_https_proxy.https_proxy.id
}

output "cloud_armor_policy_id" {
  description = "The ID of the Cloud Armor security policy"
  value       = google_compute_security_policy.cloud_armor_policy.id
}
output "lb_ip_name" {
  value = google_compute_global_address.lb_ip.name
}

output "ssl_certificate_id" {
  value = google_compute_managed_ssl_certificate.ssl_certificate.id
}

output "backend_service_id" {
  value = google_compute_backend_service.backend.id
}