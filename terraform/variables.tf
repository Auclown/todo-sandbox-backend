variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for resources"
  type        = string
  default     = "australia-southeast1"
}

variable "github_repository" {
  description = "The GitHub repository"
  type        = string
  default     = "Auclown/todo-sandbox-backend"
}
