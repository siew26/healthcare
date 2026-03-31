# healthcare

## Problem statement
The goal of this project is to design and implement an end-to-end data pipeline to analyze healthcare data, focusing on hospital admissions, patient demographics, medical conditions and financial aspects of healthcare utilization.

The pipeline automates data ingestion from an external source, processes and transforms the data into structured layers and enables efficient querying through a data warehouse.

The final output is a dashboard that provides insights into patient distribution, common medical conditions and billing trends over time, supporting data-driven decision making in healthcare analysis.

## Virtual environment Setup

python -m venv venv
activate virtual environment

## Install dependencies
after cloning the environment, run requirement file
pip install - r requirements.txt

[dataset for this project]
Make sure your Kaggle API credentials are set:
export KAGGLE_USERNAME=your_username
export KAGGLE_KEY=your_key

Run your script:
python download_data.py

## Setup GCP credentials
Create a new project named healthcare

1. Go to GCP Console → IAM & Admin → Service Accounts
2. Create a service account with:
    Storage Admin (to upload to GCS)
    BigQuery Admin (to create tables & datasets)
3. Generate a JSON key file. Save it somewhere in your project, e.g., gcp-sa.json.
4. Set environment variable in Codespaces / terminal:

export GOOGLE_APPLICATION_CREDENTIALS="path/to/gcp-sa.json"
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/../keys/healthcare-dataset.json"

This makes Python (and Bruin / Terraform) authenticate with GCP automatically.

## Install terraform
sudo apt update
sudo apt install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -v

✅ You should see something like:

Terraform v1.5.7

## install gcloud SDK
# Update packages
sudo apt update && sudo apt install -y curl apt-transport-https ca-certificates gnupg

# Add Google Cloud SDK repo
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install the SDK
sudo apt update && sudo apt install -y google-cloud-sdk

sudo apt install -y google-cloud-sdk


# Verify installation
gcloud version

# authenticate
gcloud auth application-default login

## Run terraform (in terraform folder)
terraform init
terraform plan 
terraform apply

If received error about argument QUOTA_PROJECT_ID, run the following:
gcloud auth application-default set-quota-project your_project_id

Once this works, GCS bucket and BigQuery datasets created.

## Install bruin
curl -LsSf https://getbruin.com/install/cli | sh

# restart
source ~/.bashrc

# verify installation
bruin --help

4️⃣ Initialize your project

Go to your project folder:

bruin init
Choose template: empty
Then create pipeline.yml + assets/ manually.
Rename empty to bruin