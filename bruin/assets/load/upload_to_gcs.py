"""@bruin
name: upload_data
type: python
depends:
  - download_data
@bruin"""

from google.cloud import storage
import os

BUCKET_NAME = "healthcare-dataset-491812-data-lake"
FILE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../data/modified_healthcare_dataset.csv"))
DESTINATION_BLOB = "modified_healthcare_dataset.csv"

def execute():
    if not os.path.exists(FILE_PATH):
        raise FileNotFoundError(
            f"{FILE_PATH} not found. Please run download_data.py first."
        )

    credentials_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS', '/workspaces/healthcare/keys/healthcare-dataset.json')
    project_id = os.environ.get('PROJECT_ID', 'healthcare-dataset-491812')
    from google.oauth2 import service_account
    credentials = service_account.Credentials.from_service_account_file(credentials_file)
    client = storage.Client(project=project_id, credentials=credentials)
    bucket = client.bucket(BUCKET_NAME)
    blob = bucket.blob(DESTINATION_BLOB)
    blob.upload_from_filename(FILE_PATH)
    print(f"✓ Uploaded to gs://{BUCKET_NAME}/{DESTINATION_BLOB}")
    return True

if __name__ == "__main__":
    execute()
