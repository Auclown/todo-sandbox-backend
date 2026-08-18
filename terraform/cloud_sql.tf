# Random Suffix and Password Generation
resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Compute & Storage Instance
resource "google_sql_database_instance" "todo_db_instance" {
  name             = "todo-database-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_18"
  region           = var.region

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = false

  depends_on = [
    google_project_service.cloud_sql
  ]
}

# Database
resource "google_sql_database" "todo_db" {
  name     = "todo_db"
  instance = google_sql_database_instance.todo_db_instance.name
}

# Database user
resource "google_sql_user" "db_user" {
  name     = "todo_db_user"
  instance = google_sql_database_instance.todo_db_instance.name
  password = random_password.db_password.result
}

# Secret Metadata Container
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"

  replication {
    auto {}
  }
}

# Secret Version Payload
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.db_password.result
}

# Output Connection Name
output "db_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance (used by Cloud SQL Auth Proxy)"
  value       = google_sql_database_instance.todo_db_instance.connection_name
}
