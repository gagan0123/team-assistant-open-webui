terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Cloud Build trigger for automatic builds
resource "google_cloudbuild_trigger" "main" {
  project     = var.project_id
  location    = var.region
  name        = "${var.environment}-open-webui-trigger"
  description = "Trigger for Open WebUI ${var.environment} environment"

  service_account = var.service_account_email

  source_to_build {
    uri       = var.repository_url
    ref       = "refs/heads/${var.trigger_branch}"
    repo_type = "GITHUB"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t",
        "us-central1-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}/open-webui:latest",
        ".",
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "us-central1-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}/open-webui:latest",
      ]
    }
  }
}

# Manual trigger as fallback (can be used if GitHub integration fails)
resource "google_cloudbuild_trigger" "manual" {
  project     = var.project_id
  location    = var.region
  name        = "${var.environment}-open-webui-manual-trigger"
  description = "Manual trigger for Open WebUI ${var.environment} environment"

  service_account = var.service_account_email

  source_to_build {
    uri       = var.repository_url
    ref       = "refs/heads/${var.trigger_branch}"
    repo_type = "GITHUB"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t",
        "us-central1-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}/open-webui:latest",
        ".",
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "us-central1-docker.pkg.dev/${var.project_id}/${var.artifact_repository_name}/open-webui:latest",
      ]
    }
  }
}

# IAM binding for Cloud Build to deploy to Cloud Run
resource "google_project_iam_member" "cloud_build_run_developer" {
  count   = var.auto_deploy ? 1 : 0
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${var.service_account_email}"
}
