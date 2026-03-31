terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ----------------------
# GCS Bucket (Data Lake)
# ----------------------
resource "google_storage_bucket" "data_lake" {
  name          = "${var.project_id}-data-lake"
  location      = var.bucket_location
  storage_class = var.storage_class

  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# ----------------------
# BigQuery Dataset
# ----------------------

resource "google_bigquery_dataset" "staging" {
  dataset_id = var.staging_dataset
  location   = var.bq_location
}

resource "google_bigquery_dataset" "mart" {
  dataset_id = var.mart_dataset
  location   = var.bq_location
}

resource "google_bigquery_dataset" "raw" {
  dataset_id = var.raw_dataset
  location   = var.bq_location
}