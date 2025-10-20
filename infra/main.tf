# enable important APIs early
module "project_services" {
  source     = "./modules/project_services"
  project_id = var.project_id
  region     = var.region
}

# VPC module
module "vpc" {
  source               = "./modules/vpc"
  project_id           = var.project_id
  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  subnet_services_cidr = var.subnet_services_cidr
  subnet_data_cidr     = var.subnet_data_cidr
  region               = var.region
}

# Artifact Registry
module "artifact" {
  source      = "./modules/artifact_registry"
  project_id  = var.project_id
  name_prefix = var.name_prefix
  region      = var.region
}

# Cloud Storage (object storage)
module "gcs" {
  source      = "./modules/gcs_bucket"
  project_id  = var.project_id
  name_prefix = var.name_prefix
  region      = var.region
  env         = var.env
}

# Pub/Sub
module "pubsub" {
  source     = "./modules/pubsub"
  project_id = var.project_id
  name       = "${var.name_prefix}-${var.env}-events"
}

# Redis (MemoryStore)
module "redis" {
  source         = "./modules/redis"
  project_id     = var.project_id
  region         = var.region
  name           = "${var.name_prefix}-${var.env}-redis"
  network        = module.vpc.vpc_self_link
  tier           = "BASIC"
  memory_size_gb = 1
}

# Cloud SQL (Postgres) - private IP
module "cloudsql" {
  source            = "./modules/cloudsql_postgres"
  project_id        = var.project_id
  region            = var.region
  name_prefix       = var.name_prefix
  db_name           = var.db_name
  db_user           = var.db_user
  db_tier           = var.db_tier
  network           = module.vpc.vpc_self_link
  private_ip_subnet = module.vpc.subnet_data_self_link
}

# GKE Autopilot cluster
module "gke" {
  source      = "./modules/gke_autopilot"
  project_id  = var.project_id
  name_prefix = var.name_prefix
  region      = var.region
  network     = module.vpc.vpc_self_link
  subnetwork  = module.vpc.subnet_services_self_link
  env         = var.env
}

resource "google_compute_network_endpoint_group" "app_neg" {
  name         = "${var.name_prefix}-neg"
  network      = module.vpc.network_self_link
  subnetwork   = element(module.vpc.subnet_self_links, 0)
  default_port = var.default_port
  zone         = "${var.region}-a"
}


# Load Balancer 
module "load_balancer" {
  depends_on            = [module.gke]
  source                = "./modules/load-balancer"
  count                 = var.create_load_balancer ? 1 : 0
  vpc_id                = module.vpc.network_self_link
  subnetwork            = length(module.vpc.subnet_self_links) > 0 ? module.vpc.subnet_self_links[0] : null
  lb_name               = var.lb_name
  gcp_zone              = var.gcp_zone
  domain_name           = var.domain_name
  neg_name              = var.neg_name
  network_endpoint_type = "GCE_VM_IP_PORT"
  default_port          = var.default_port
  lb_enable_logging     = var.lb_enable_logging
  dns-zone-name         = var.dns-zone-name
  blocked_ip_ranges     = var.blocked_ip_ranges
  enable_cdn            = var.enable_cdn
  health_check_path     = var.health_check_path
  cluster_name          = module.gke.cluster_name
  gcp_project           = var.project_id
  location              = var.region
  negs = [
    {
      name      = "gke-neg"
      self_link = google_compute_network_endpoint_group.app_neg.self_link
    }
  ]
  create_gke_ingress    = var.create_gke_ingress
}


# Cloud Run service for worker
module "cloudrun_worker" {
  source          = "./modules/cloudrun_service"
  project_id      = var.project_id
  name_prefix     = var.name_prefix
  region          = var.cloudrun_region
  image           = "${module.artifact.repo_location}/${var.name_prefix}-worker:latest"
  service_account = "${var.name_prefix}-${var.env}-worker-sa@${var.project_id}.iam.gserviceaccount.com"
  env_vars = {
    PUBSUB_TOPIC = module.pubsub.topic_name
    BUCKET_NAME  = module.gcs.bucket_name
  }
}

# IAM setup (service accounts & roles)
module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  name_prefix = var.name_prefix
  env         = var.env
}

# Secret Manager (placeholder secret)
module "secrets" {
  source      = "./modules/secret_manager"
  project_id  = var.project_id
  name_prefix = var.name_prefix
  secrets = {
    db_password = "REPLACE_WITH_SECURE_VALUE"
  }
}
