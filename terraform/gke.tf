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