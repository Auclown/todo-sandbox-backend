resource "google_artifact_registry_repository" "todo_backend" {
  location      = var.region
  repository_id = "todo-backend-repo"
  description   = "Docker repository for Todo API images"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry]
}