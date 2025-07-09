resource "google_cloudbuildv2_repository" "openwebui_repo" {
  name = var.repository_name
  parent_connection = var.connection_resource_path
  location = var.location
}

resource "google_cloudbuildv2_trigger" "openwebui_trigger" {
  project = var.project_id
  location = var.location
  name = "${var.environment}-openwebui-build-trigger"

  repository_event_config {
    repository = google_cloudbuildv2_repository.openwebui_repo.id
    pull_request {
      branch_regex = var.branch_regex
      // For PRs, we typically want to build and test, but not deploy
      // auto_deploy = false 
    }
  }

  build_config {
    # Use the cloudbuild.yaml in the root of the repository
    source {
      repo_source {
        dir = "."
        branch_name = var.branch_regex
      }
    }
    steps {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.artifact_registry_url}/open-webui:latest", "."]
    }
    steps {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.artifact_registry_url}/open-webui:latest"]
    }
  }
}
