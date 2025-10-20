###################### Reserve an External IP Address ######################
resource "google_compute_global_address" "lb_ip" {
  name = "${var.lb_name}-ip"
}

###################### Managed SSL Certificate ######################
resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name = replace(lower("ssl-${var.domain_name}"), "/[^a-z0-9-]/", "")
  managed {
    domains = [var.domain_name]
  }
}
###################### NEG for GKE ######################
data "google_compute_network_endpoint_group" "negs" {
  for_each = { for neg in var.negs : "${neg.name}-${neg.zone}" => neg }

  name    = each.value.name
  zone    = each.value.zone
  project = var.gcp_project
}

###################### Health Check ######################
resource "google_compute_health_check" "lb_health_check" {
  name               = "${var.lb_name}-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port_specification = "USE_FIXED_PORT"
    request_path       = "/"
  }
}
###################### Backend Service ######################
resource "google_compute_backend_service" "backend" {
  name                  = "${var.lb_name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 300
  enable_cdn            = var.enable_cdn
  dynamic "backend" {
    for_each = data.google_compute_network_endpoint_group.negs
    content {
      group                 = backend.value.id
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 100
    }
  }
  health_checks   = [google_compute_health_check.lb_health_check.id]
  security_policy = google_compute_security_policy.cloud_armor_policy.id

  dynamic "log_config" {
    for_each = var.lb_enable_logging ? [1] : []
    content {
      enable      = true
      sample_rate = 1.0
    }
  }
}

###################### URL Map ######################
resource "google_compute_url_map" "url_map" {
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.backend.id
}

###################### Target HTTPS Proxy ######################
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
}

###################### Global Forwarding Rule ######################
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.lb_name}-https-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy.id
  port_range            = "443"
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

###################### Cloud Armor Security Policy ######################
resource "google_compute_security_policy" "cloud_armor_policy" {
  name        = "${var.lb_name}-cloud-armor-policy"
  description = "Cloud Armor policy for ${var.lb_name} load balancer"
  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.blocked_ip_ranges
      }
    }
    description = "Block specific IP ranges"
  }
  rule {
    action      = "deny(403)"
    priority    = 1001
    description = "Block traffic from specific countries"
    match {
      expr {
        expression = "origin.region_code == 'PK' || origin.region_code == 'BD' || origin.region_code == 'KP' || origin.region_code == 'CN'"
      }
    }
  }
  rule {
    action      = "deny(403)"
    priority    = 1002
    description = "Prevent Cross-site scripting attacks"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable')"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1003
    description = "Prevent session fixation attacks"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sessionfixation-v33-stable')"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1004
    description = "Prevent Java-based attacks"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('java-v33-stable')"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1005
    description = "Prevent protocol-based attacks"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('protocolattack-v33-stable')"
      }
    }
  }
  rule {
    action      = "allow"
    priority    = 2147483647
    description = "default allow rule"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
