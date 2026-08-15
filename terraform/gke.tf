#trivy:ignore:GCP-0061
resource "google_container_cluster" "primary" {
  name     = "todo-cluster"
  location = var.region

  # Google manages node and scaling
  enable_autopilot = true

  # Prevents Terraform from hanging if backend gets deleted later
  deletion_protection = false

  depends_on = [
    google_project_service.container_api
  ]
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "gke_node_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}
