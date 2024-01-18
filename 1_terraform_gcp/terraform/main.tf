terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }
  }

}

provider "google" {
  project = "ny-taxi-2024"
  region  = "us-east4"
}

resource "google_storage_bucket" "data-lake-bucket" {
  name          = "ny-taxi-2024-terraform"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 // days
    }
  }
}
