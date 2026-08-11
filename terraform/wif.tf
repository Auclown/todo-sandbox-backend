# 1. Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions pipelines"
}

# 2. Create OIDC Provider targeting GitHub
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
  }

  # Prevent other GitHub repo from using this WIF provider
  attribute_condition = "assertion.repository_owner == '${split("/", var.github_repository)[0]}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 3. Create Service Account for CI/CD pipeline execution
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer Service Account"
}

# 4. Bind GitHub Repository to the Service Account
resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# Grant necessary roles to the deployment Service Account
resource "google_project_iam_member" "sa_artifact_admin" {
  project = var.project_id
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
  role    = "roles/artifactregistry.writer"
}

# Grant Editor permissions to the deployment Service Account
resource "google_project_iam_member" "sa_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Secret Manager Admin permissions to the deployment Service Account
resource "google_project_iam_member" "sa_secret_admin" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Allow the GitHub Actions Service Account to deploy workloads to GKE
resource "google_project_iam_member" "sa_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Output the WIF Provider name needed by GitHub Actions
output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "wif_service_account_email" {
  value = google_service_account.github_actions_sa.email
}