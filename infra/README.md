# Terraform modules for Autovyn - GCP DevOps Assessment

## What this repo creates
- VPC (custom) with subnets + Cloud NAT
- Artifact Registry (Docker)
- Cloud Storage bucket (uniform access)
- Pub/Sub topic + subscription
- MemoryStore (Redis)
- Cloud SQL (Postgres) with private IP, automated backups, PITR enabled
- GKE Autopilot cluster (Workload Identity enabled)
- Cloud Run service (worker example)
- Service accounts + IAM bindings
- Secret Manager secrets

## How to use
1. Install `terraform` and `gcloud`, authenticate: `gcloud auth application-default login`
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update values.
3. Run:
```bash
    terraform init
    terraform plan -out plan.out
    terraform apply plan.out
```

4. After apply:
- Use `terraform output` to get cluster name, SQL instance connection name, bucket name.
- For GKE work, run `gcloud container clusters get-credentials <cluster> --region <region> --project <project_id>`

## Notes, trade-offs & next steps
- GKE is Autopilot for reduced infra ops. If you need node pool control (node-level PodDisruption budgets, custom node pools), use Standard mode.
- Cloud SQL private IP is used (no public DB IP).
- Workload Identity is configured for GKE (cluster). Map k8s service accounts to GCP service accounts in your k8s manifests.
- Artifact Registry path is output. CI should authenticate via OIDC or `gcloud` to push images.
- Cloud Run image reference in module is a placeholder — ensure your CI publishes images to Artifact Registry and update `cloudrun_worker.image`.
- API Gateway, Cloud Armor, Ingress-to-GKE NEG and advanced LB config are not fully automated here (you can add them with google_compute_backend_service + google_compute_url_map + google_compute_target_https_proxy or use Kubernetes Ingress + GCLB via k8s ingress). I focused on the core mandatory infra requested (Autopilot, Cloud SQL Postgres, Cloud Run).

## Security
- Secrets should be injected from Secret Manager at deploy time (NOT stored in terraform state). The included secret manager module demonstrates how to create secrets, but for production you should avoid placing secret values in terraform state.

## Cost control
- Labels should be added to all resources in modules (you can extend modules to include labels = { env = var.env, owner = "your-team", cost-center = "..." }).
- Consider smaller DB/Redis sizes for dev; increase for prod.

