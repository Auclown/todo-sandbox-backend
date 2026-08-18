# Secret container for Django Secret Key
resource "google_secret_manager_secret" "django_secret_key" {
  secret_id = "django-secret-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager]
}

# Initial dummy version - override this with real secret values later
resource "google_secret_manager_secret_version" "django_secret_key_initial" {
  secret      = google_secret_manager_secret.django_secret_key.id
  secret_data = "django-insecure-sandbox-key-change-me"
}
