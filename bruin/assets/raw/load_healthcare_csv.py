"""@bruin
name: load_gcs_to_bq
type: python
depends:
  - upload_data
@bruin"""

# depends on: google-cloud-bigquery

from google.cloud import bigquery
import os

def execute():
    GCS_BUCKET = os.environ.get('GCS_BUCKET', 'healthcare-dataset-491812-data-lake')
    GCS_FILE = os.environ.get('GCS_FILE', 'modified_healthcare_dataset.csv')
    GCS_URI = f'gs://{GCS_BUCKET}/{GCS_FILE}'
    BQ_PROJECT = os.environ.get('PROJECT_ID', 'healthcare-dataset-491812')
    BQ_DATASET = os.environ.get('RAW_DATASET', 'healthcare_raw')
    BQ_TABLE = 'load_raw'

    os.environ.setdefault('GOOGLE_APPLICATION_CREDENTIALS', '/workspaces/healthcare/keys/healthcare-dataset.json')
    client = bigquery.Client(project=BQ_PROJECT)
    table_id = f"{BQ_PROJECT}.{BQ_DATASET}.{BQ_TABLE}"

    job_config = bigquery.LoadJobConfig(
        skip_leading_rows=1,
        autodetect=True,
        source_format=bigquery.SourceFormat.CSV,
        write_disposition="WRITE_TRUNCATE",
    )

    load_job = client.load_table_from_uri(GCS_URI, table_id, job_config=job_config)
    result = load_job.result()
    print(f"✓ Loaded {load_job.output_rows} rows into {table_id}")
    return True

if __name__ == "__main__":
    execute()
