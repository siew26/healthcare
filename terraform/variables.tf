variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_location" {
  description = "GCS bucket location"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "GCS storage class"
  type        = string
  default     = "STANDARD"
}

variable "staging_dataset" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "healthcare_staging"
}

variable "mart_dataset" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "healthcare_mart"
}

variable "raw_dataset" {
  description = "BigQuery raw dataset ID"
  type        = string
  default     = "healthcare_raw"
}

variable "bq_location" {
  description = "BigQuery location"
  type        = string
  default     = "US"
}