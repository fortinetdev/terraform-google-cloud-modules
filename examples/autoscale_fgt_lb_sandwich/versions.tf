terraform {
  required_version = ">=0.13.0"
  required_providers {
    google = {
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
