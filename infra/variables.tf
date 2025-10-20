variable "name_prefix" {
  type    = string
  default = "autovyn"
}

variable "env" {
  type    = string
  default = "dev"
}
################################

variable "project_id" {
  type = string
}

variable "billing_account" {
  type        = string
  description = "Billing account ID"
  default     = ""
}

variable "region" {
  type    = string
  default = "ap-south1"
}

variable "zone" {
  type    = string
  default = "ap-south1-a"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_services_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "subnet_data_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

# Cloud SQL
variable "db_name" {
  type    = string
  default = "appdb"
}
variable "db_user" {
  type    = string
  default = "appuser"
}
variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

# Cloud Run
variable "cloudrun_region" {
  type    = string
  default = "ap-south1"
}

# Load Balancer


variable "lb_name" {
  description = "Name of the Load Balancer"
  type        = string
  default = "gke-lb"
}

variable "domain_name" {
  description = "Domain name for the TLS certificate"
  type        = string
  default = "autovyn-dev.opswithsunil.click"
}
variable "gcp_zone" {
  description = "The GCP zone where resources will be deployed"
  type        = string
  default     = "asia-south1-a"
}

variable "create_load_balancer" {
  description = "Set to true to create a GKE cluster"
  type        = bool
  default     = false
}

variable "neg_name" {
  type        = string
  default     = "gke-neg"
  description = "Name of the network endpoint group"
}

variable "default_port" {
  type        = number
  description = "Default service port for the load balancer"
  default     = 8080
}

variable "lb_enable_logging" {
  type        = bool
  description = "Enable Cloud Load Balancer logging"
  default     = true
}

variable "dns-zone-name" {
  type        = string
  description = "DNS managed zone name"
  default     = ""
}

variable "blocked_ip_ranges" {
  type        = list(string)
  description = "List of CIDR ranges to block"
  default     = []
}

variable "enable_cdn" {
  type        = bool
  description = "Enable Cloud CDN on the load balancer"
  default     = false
}

variable "health_check_path" {
  type        = string
  description = "Health check path for backend service"
  default     = "/healthz"
}

variable "cluster_name" {
  type        = string
  default = "autovyn-dev-gke"
  description = "Name of GKE cluster"
}

variable "negs" {
  type        = list(string)
  description = "List of network endpoint group self links"
  default     = []
}

variable "create_gke_ingress" {
  type        = bool
  description = "Whether to create GKE ingress resources"
  default     = true
}

variable "create_gke" {
  type        = bool
  description = "Flag to create and connect to GKE cluster"
  default     = true
}