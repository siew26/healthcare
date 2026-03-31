output "bucket_name" {
  description = "GCS bucket name"
  value       = google_storage_bucket.data_lake.name
}

output "staging" {
  description = "BigQuery staging dataset"
  value       = google_bigquery_dataset.staging.dataset_id
}

output "mart" {
  description = "BigQuery marts dataset"
  value       = google_bigquery_dataset.mart.dataset_id
}

output "raw" {
  description = "BigQuery raw dataset"
  value       = google_bigquery_dataset.raw.dataset_id
}