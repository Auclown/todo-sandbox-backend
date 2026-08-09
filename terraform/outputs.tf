output "artifact_registry_url" {
  description = "Full URL of the Docker repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.todo_backend.repository_id}"
}

output "django_secret_id" {
  description = "Secret Manager ID for Django Secret Key"
  value       = google_secret_manager_secret.django_secret_key.secret_id
}