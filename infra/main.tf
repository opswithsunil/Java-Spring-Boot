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
