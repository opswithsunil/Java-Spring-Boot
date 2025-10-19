variable "project_id" { type = string }
variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "subnet_services_cidr" { type = string }
variable "subnet_data_cidr" { type = string }
variable "region" { type = string }

resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "services" {
  name                     = "${var.name_prefix}-subnet-services"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_services_cidr
  network                  = google_compute_network.vpc.self_link
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "data" {
  name                     = "${var.name_prefix}-subnet-data"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_data_cidr
  network                  = google_compute_network.vpc.self_link
  region                   = var.region
  private_ip_google_access = true
}

# Allocate an internal range for private service connection
resource "google_compute_global_address" "private_service_range" {
  name          = "${var.name_prefix}-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.self_link
}

# Private VPC connection for Cloud SQL / Redis
resource "google_service_networking_connection" "private_vpc_conn" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

# Cloud Router + NAT for outbound access
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  project = var.project_id
  network = google_compute_network.vpc.self_link
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}-nat"
  router                             = google_compute_router.router.name
  project                            = var.project_id
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_services_self_link" {
  value = google_compute_subnetwork.services.self_link
}

output "subnet_data_self_link" {
  value = google_compute_subnetwork.data.self_link
}