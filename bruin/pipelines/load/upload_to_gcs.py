"""@bruin
name: upload_to_gcs
type: python
@bruin"""

from google.cloud import storage
import os

BUCKET_NAME = "healthcare-dataset-491812-data-lake"
# Path to the CSV at project root, regardless of where this script is
FILE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../data/modified_healthcare_dataset.csv"))

DESTINATION_BLOB = "modified_healthcare_dataset.csv"

def upload_to_gcs():
    if not os.path.exists(FILE_PATH):
        raise FileNotFoundError(
            f"{FILE_PATH} not found. Please run download_data.py first."
        )
    
    client = storage.Client()
    bucket = client.bucket(BUCKET_NAME)
    blob = bucket.blob(DESTINATION_BLOB)

    blob.upload_from_filename(FILE_PATH)

    print(f"File uploaded to gs://{BUCKET_NAME}/{DESTINATION_BLOB}")

if __name__ == "__main__":
    upload_to_gcs()