variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-default-vpc"
}

variable "create_subnet" {
  description = "Whether to create a new subnet"
  type        = bool
  default     = false
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnet"
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = false
}

variable "router_name" {
  description = "Name of the router for NAT gateway"
  type        = string
  default     = "my-router"
}

variable "create_tls_certificate" {
  description = "Whether to create a TLS certificate"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the TLS certificate"
  type        = string
  default     = ""
}

variable "create_load_balancer" {
  description = "Whether to create a load balancer"
  type        = bool
  default     = false
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
  default     = "my-load-balancer"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "lb_enable_logging" {
  description = "Enable logging for the load balancer backend"
  type        = bool
  default     = false
}

variable "neg_name" {
  description = "Name of the Network Endpoint Group (NEG)"
  type        = string
  default     = "my-neg"
}
variable "gcp_project" {
  description = "Google Cloud project ID"
  type        = string
}

variable "network_endpoint_type" {
  description = "Type of network endpoint for the NEG"
  type        = string
  default     = "GCE_VM_IP_PORT"
}

variable "vpc_id" {
  description = "VPC ID for the load balancer"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork ID for the NEG"
  type        = string
  default     = "default"
}

variable "default_port" {
  description = "Default port for the NEG"
  type        = number
  default     = 80
}
variable "blocked_ip_ranges" {
  description = "List of IP ranges to block in Cloud Armor"
  type        = list(string)
  default     = ["192.168.0.0/24", "10.0.0.0/8"]
}
variable "dns-zone-name" {
  description = "Subnetwork ID for the NEG"
  type        = string
}
variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/healthz"
}

variable "enable_cdn" {
  description = "Enable Cloud CDN"
  type        = bool
  default     = false
}
variable "create_gke_ingress" {
  type = bool
}
variable "cluster_name" {
  type = string
}
variable "location" {
  description = "The region of the GKE cluster"
  default     = "us-east1"
  type        = string
}
variable "ingress_negs" {
  type = list(object({
    name = string
    zone = string
  }))
  default = [
    {
      name = "k8s1-.*ingress-nginx"
      zone = "asia-south1-a"
    }
  ]
}
variable "negs" {
  description = "List of NEGs"
  type = list(object({
    name      = string
    self_link = string
  }))
}

variable "enable_lb_logging" {
  description = "Enable logging for load balancer components"
  type        = bool
  default     = true
}

variable "lb_log_sample_rate" {
  description = "Sampling rate for load balancer logs (0.0 - 1.0)"
  type        = number
  default     = 1.0
}