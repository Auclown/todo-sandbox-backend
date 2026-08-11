resource "google_container_cluster" "primary" {
  name     = "todo-cluster"
  location = var.region

  # Google manages node and scaling
  enable_autopilot = true

  # Prevents Terraform from hanging if backend gets deleted later
  deletion_protection = false

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "Allow GitHub Actions dynamic runners"
    }
  }

  depends_on = [
    google_project_service.container_api
  ]
}