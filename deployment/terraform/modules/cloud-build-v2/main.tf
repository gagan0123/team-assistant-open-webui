resource "google_cloudbuildv2_connection" "github_connection" {
  project  = var.project_id
  location = var.location
  name     = var.connection_id

  github_config {
    app_installation_id = var.github_app_installation_id
  }
}

resource "google_cloudbuildv2_repository" "openwebui_repo" {
  project           = var.project_id
  location          = var.location
  name              = var.repository_name
  parent_connection = google_cloudbuildv2_connection.github_connection.name

  remote_uri = "https://github.com/${var.github_owner}/${var.repository_name}.git"
}

resource "google_cloudbuild_trigger" "openwebui_trigger" {
  project  = var.project_id
  location = var.location
  name     = "${var.environment}-openwebui-build-trigger"

  github {
    owner = var.github_owner
    name  = var.repository_name
    pull_request {
      branch = var.branch_regex
    }
  }

  build {
    source {
      repo_source {
        repo_name   = var.repository_name
        branch_name = var.branch_regex
      }
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.artifact_registry_url}/open-webui:latest", "."]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.artifact_registry_url}/open-webui:latest"]
    }
  }
}
