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
