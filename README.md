# Healthcare Data Pipeline

## Overview

An end-to-end data pipeline that ingests healthcare data from Kaggle, processes it through a multi-layer architecture (raw → staging → mart), and loads it into Google BigQuery for analysis.

**Pipeline layers:**

| Layer | Asset | Output |
|---|---|---|
| Extract | `download_data.py` | `data/modified_healthcare_dataset.csv` |
| Load | `upload_to_gcs.py` | GCS Bucket (data lake) |
| Raw | `load_healthcare_csv.py` | `healthcare_raw.load_raw` |
| Staging | `stg_admissions.sql` | `healthcare_staging.stg_admissions` |
| Staging | `stg_patients.sql` | `healthcare_staging.stg_patients` |
| Mart | `dim_hospitals.sql` | `healthcare_mart.dim_hospitals` |
| Mart | `dim_medical_conditions.sql` | `healthcare_mart.dim_medical_conditions` |
| Mart | `fact_hospital_admissions.sql` | `healthcare_mart.fact_hospital_admissions` |
| Mart | `fact_admissions_by_hospital.sql` | `healthcare_mart.fact_admissions_by_hospital` |
| Mart | `fact_admissions_by_condition.sql` | `healthcare_mart.fact_admissions_by_condition` |
| Mart | `fact_admissions_by_demographics.sql` | `healthcare_mart.fact_admissions_by_demographics` |

> **Note:** The mart layer filters data to **2020–2023** to focus the analysis on a consistent 4-year window. The full raw dataset (~55,500 rows) spanning 2019–2024 remains intact in `healthcare_raw.load_raw`.

**Tech stack:** Python · SQL · Google Cloud Storage · Google BigQuery · Terraform · Bruin

---

## Problem Statement

Healthcare systems generate large volumes of admissions data, yet insights about patient flow, medical conditions, and financial utilization are often fragmented and difficult to access. This project addresses that gap by building a fully automated data pipeline that:

- Ingests raw hospital admissions records from an external source
- Cleans and transforms data across structured warehouse layers
- Exposes analytics-ready tables for reporting and dashboarding

The goal is to enable data-driven decision making around patient distribution, common medical conditions, hospital utilization, and billing trends over time.

---

## Dataset

**Source:** [Healthcare Dataset on Kaggle](https://www.kaggle.com/datasets/eduardolicea/healthcare-dataset)

~55,500 synthetic hospital admission records across hospitals in the United States.

| Column | Description |
|---|---|
| `Name` | Patient name |
| `Age` | Patient age |
| `Gender` | Patient gender |
| `Blood Type` | Patient blood type |
| `Medical Condition` | Primary diagnosis (e.g., Cancer, Flu, Asthma) |
| `Date of Admission` | Admission date |
| `Discharge Date` | Discharge date |
| `Length of Stay` | Days admitted |
| `Hospital` | Hospital name |
| `Doctor` | Attending physician |
| `Admission Type` | Emergency / Elective / Urgent |
| `Insurance Provider` | Insurance company |
| `Billing Amount` | Total billed amount (USD) |
| `Room Number` | Room assigned |
| `Medication` | Medication prescribed |
| `Test Results` | Normal / Abnormal / Inconclusive |

---

## Key Research Questions

This pipeline is designed to help answer:

1. **Patient distribution** — Which hospitals have the highest admission volumes? How are patients distributed by age group and gender?
2. **Medical conditions** — What are the most common diagnoses? How does condition prevalence vary across hospitals?
3. **Admission patterns** — What is the breakdown of Emergency vs. Elective vs. Urgent admissions? Are there seasonal trends?
4. **Billing & financial** — What is the average billing amount by condition and hospital? Which conditions are the most expensive to treat?

---

## Prerequisites

Before you begin, make sure you have:

- A **Google Cloud Platform (GCP)** account with billing enabled
- A **Kaggle** account with API access (optional — see Step 3)
- Access to a **Linux/macOS terminal** (or GitHub Codespaces)

> A pre-processed CSV is already included in the `data/` folder — Kaggle credentials are only needed if you want to download fresh data.

---

## Step 1 — Clone the Repository

```bash
git clone https://github.com/siew26/healthcare.git
cd healthcare
```

---

## Step 2 — Set Up Python Environment

```bash
python -m venv venv
source venv/bin/activate        # Linux / macOS
# venv\Scripts\activate         # Windows

pip install -r requirements.txt
```

---

## Step 3 — Configure Data Source

You have two options for providing the source data:

### Option A — Use the included CSV (recommended for quick testing)

The repository already includes a pre-processed CSV at `data/modified_healthcare_dataset.csv`. The pipeline's `upload_to_gcs.py` asset reads from this path by default, so **no Kaggle account is needed**.

Simply skip to [Step 4](#step-4--set-up-gcp-project) — the file is ready to use.

### Option B — Download fresh data from Kaggle

If you want Bruin to download the latest dataset directly from Kaggle:

1. Log in to [kaggle.com](https://www.kaggle.com) → Account → API → **Create New Token**
2. Save the downloaded `kaggle.json` to `keys/kaggle.json`
3. Export your credentials:

```bash
export KAGGLE_USERNAME=your_kaggle_username
export KAGGLE_KEY=your_kaggle_api_key
```

Or place `kaggle.json` at `~/.kaggle/kaggle.json` (Kaggle's default location).

The `download_data` asset will run first and overwrite the file in `data/` with a fresh download.

---

## Step 4 — Set Up GCP Project

### 4a. Create a GCP project

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project (e.g., `healthcare-dataset`)
3. Note your **Project ID** (shown in the project selector, e.g., `healthcare-dataset-491812`)

### 4b. Create a service account

1. Go to **IAM & Admin → Service Accounts**
2. Click **Create Service Account**, name it (e.g., `healthcare-sa`)
3. Grant the following roles:
   - `Storage Admin` — to upload files to GCS
   - `BigQuery Admin` — to create datasets and tables
4. Click **Done**, then open the service account
5. Go to **Keys → Add Key → Create new key → JSON**
6. Save the downloaded JSON file to `keys/healthcare-dataset.json`

### 4c. Set environment variable

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/keys/healthcare-dataset.json"
```

> Add this line to your `~/.bashrc` or `~/.zshrc` to persist it across sessions.

---

## Step 5 — Install Terraform

```bash
sudo apt update && sudo apt install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -v
```

Expected output: `Terraform v1.5.7`

---

## Step 6 — Provision GCP Infrastructure with Terraform

Terraform creates the GCS bucket and three BigQuery datasets (`healthcare_raw`, `healthcare_staging`, `healthcare_mart`).

### 6a. Update `terraform/terraform.tfvars`

Open `terraform/terraform.tfvars` and replace the project ID with your own:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
```

### 6b. Authenticate with gcloud (required for Terraform provider)

```bash
# Install gcloud SDK if not already installed
sudo apt update && sudo apt install -y curl apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt update && sudo apt install -y google-cloud-sdk

# Authenticate
gcloud auth application-default login
```

If you get a `QUOTA_PROJECT_ID` error, run:

```bash
gcloud auth application-default set-quota-project your-gcp-project-id
```

### 6c. Apply Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
cd ..
```

Type `yes` when prompted. Once complete, you should have:
- GCS bucket: `your-project-id-data-lake`
- BigQuery datasets: `healthcare_raw`, `healthcare_staging`, `healthcare_mart`

---

## Step 7 — Install Bruin CLI

[Bruin](https://getbruin.com) is the pipeline orchestrator that runs all assets in dependency order.

```bash
curl -LsSf https://getbruin.com/install/cli | sh
source ~/.bashrc    # or restart terminal

bruin --version     # verify installation
```

---

## Step 8 — Configure Bruin Connections

Bruin reads its configuration from `.bruin.yml` at the **root of the repository**.

Open `.bruin.yml` and update the `project_id` and `service_account_file` values to match your own:

```yaml
default_environment: default
environments:
    default:
        connections:
            google_cloud_platform:
                - name: "bigquery"
                  project_id: "your-gcp-project-id"
                  service_account_file: "/absolute/path/to/keys/healthcare-dataset.json"
                - name: "gcp-default"
                  project_id: "your-gcp-project-id"
                  service_account_file: "/absolute/path/to/keys/healthcare-dataset.json"
```

> Use the **absolute path** to your service account JSON file.

---

## Step 9 — Run the Pipeline

### 9a. Validate all assets

From the `bruin/` directory, run:

```bash
cd bruin
bruin validate .
```

Expected output — you should see **12 assets** validated:

```
Validating pipeline: healthcare_pipeline
✅ download_data
✅ upload_data
✅ load_gcs_to_bq
✅ healthcare_raw.raw_data
✅ healthcare_staging.stg_admissions
✅ healthcare_staging.stg_patients
✅ healthcare_mart.dim_hospitals
✅ healthcare_mart.dim_medical_conditions
✅ healthcare_mart.fact_hospital_admissions
✅ healthcare_mart.fact_admissions_by_hospital
✅ healthcare_mart.fact_admissions_by_condition
✅ healthcare_mart.fact_admissions_by_demographics

Found 12 assets.
```

If you see **0 assets**, check the [Troubleshooting](#troubleshooting) section.

### 9b. Run the full pipeline

```bash
cd bruin
bruin run .
```

The pipeline runs assets in dependency order. Expect it to take **20–40 seconds**.

Expected output:

```
Starting pipeline: healthcare_pipeline
[PASS] download_data
[PASS] upload_data
[PASS] load_gcs_to_bq
[PASS] healthcare_raw.raw_data
[PASS] healthcare_staging.stg_admissions
[PASS] healthcare_staging.stg_patients
[PASS] healthcare_mart.dim_hospitals
[PASS] healthcare_mart.dim_medical_conditions
[PASS] healthcare_mart.fact_hospital_admissions
[PASS] healthcare_mart.fact_admissions_by_hospital
[PASS] healthcare_mart.fact_admissions_by_condition
[PASS] healthcare_mart.fact_admissions_by_demographics

Finished! 12/12 assets passed.
```

### 9c. Run a single asset (optional)

```bash
bruin run assets/mart/dim_hospitals.sql
```

---

## Step 10 — Verify Results in BigQuery

1. Go to [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Select your project
3. You should see three datasets with the following tables:

| Dataset | Table | Description |
|---|---|---|
| `healthcare_raw` | `load_raw` | Raw CSV loaded from GCS (~55,500 rows) |
| `healthcare_staging` | `stg_admissions` | Cleaned admission records |
| `healthcare_staging` | `stg_patients` | Deduplicated patient master |
| `healthcare_mart` | `dim_hospitals` | Hospital dimension |
| `healthcare_mart` | `dim_medical_conditions` | Medical condition dimension |
| `healthcare_mart` | `fact_hospital_admissions` | Core fact table |
| `healthcare_mart` | `fact_admissions_by_hospital` | Aggregated by hospital |
| `healthcare_mart` | `fact_admissions_by_condition` | Aggregated by condition |
| `healthcare_mart` | `fact_admissions_by_demographics` | Aggregated by demographics |

---

## Project Structure

```
healthcare/
├── .bruin.yml                  # Root Bruin config (GCP connections)
├── requirements.txt            # Python dependencies
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # GCS bucket + BigQuery datasets
│   ├── variables.tf
│   └── terraform.tfvars        # ← update with your project_id
├── keys/                       # Credentials (gitignored)
│   ├── healthcare-dataset.json # GCP service account key
│   └── kaggle.json             # Kaggle API credentials
├── data/                       # Downloaded CSV (gitignored)
└── bruin/                      # Pipeline definition
    ├── pipeline.yml            # Pipeline name, schedule, connections
    └── assets/
        ├── extract/
        │   └── download_data.py        # Downloads CSV from Kaggle
        ├── load/
        │   └── upload_to_gcs.py        # Uploads CSV to GCS
        ├── raw/
        │   ├── load_healthcare_csv.py  # Loads GCS → BigQuery raw
        │   └── validate_raw_load.sql   # Validates raw row count
        ├── staging/
        │   ├── stg_admissions.sql
        │   └── stg_patients.sql
        └── mart/
            ├── dim_hospitals.sql
            ├── dim_medical_conditions.sql
            ├── fact_hospital_admissions.sql
            ├── fact_admissions_by_hospital.sql
            ├── fact_admissions_by_condition.sql
            └── fact_admissions_by_demographics.sql
```

---

## Key Findings

> Based on analysis of **2020–2023** hospital admission records across four Chicago hospitals. Data is filtered at the mart layer — the full dataset (2019–2024) is preserved in the raw layer.

### 1. Hospital Admissions Distribution
All four hospitals — **Northwestern Memorial Hospital** (11,187), **UChicago Medicine** (11,158), **UI Health** (11,154), and **Loyola University Medical Center** (10,760) — show near-equal admission volumes. This suggests a balanced patient distribution across the Chicago healthcare network, with no single hospital significantly overburdened relative to the others.

Seniors represent the **largest admission group**, followed by Middle Age, Young Adults, and Pediatric patients — consistent with the expectation that older populations use hospital services more frequently. Female patients show higher admission counts than male patients across all age groups except Young Adults.

### 2. Medical Condition Prevalence
Admissions are distributed almost evenly across all 8 conditions (12.3%–12.7%), indicating no single condition dominates overall. When broken down by hospital, the condition mix remains **consistent across all four sites** — each hospital's leading condition shifts slightly (Heart disease at Northwestern Memorial, Obesity at UI Health, Diabetes at UChicago Medicine, Cancer at Loyola), but no hospital is heavily specialised in any single condition. This uniformity suggests patients are not being triaged to hospitals based on condition type.

### 3. Admission Patterns
The admission type breakdown is:
- **Emergency: 36.4%** (16,124 admissions) — the largest category
- **Elective: 23.8%** (10,544)
- **Urgent: 21.1%** (9,344)
- **Routine: 18.6%** (8,247)

Over one-third of admissions are emergency cases, highlighting the acute care burden on these hospitals. Monthly admissions range from approximately **3,400 to 3,900**, with a mild **peak around July–August** and a dip in February, potentially reflecting summer activity-related incidents.

### 4. Billing & Financial
Average billing is consistent across hospitals (~$21,750–$22,000), confirming no hospital charges significantly more than others. However, billing varies significantly by condition:

| Condition | Avg Billing | Avg Length of Stay |
|---|---|---|
| Cancer | $64,688 | 36.5 days |
| Heart Disease | $44,993 | 26.9 days |
| Alzheimer's | $32,663 | 54.4 days |
| Diabetes | $12,511 | 8.1 days |
| Obesity | $10,068 | 6.0 days |
| Asthma | $5,029 | 3.5 days |
| Infections | $2,748 | 5.5 days |
| Flu | $2,744 | 2.5 days |

**Cancer** is the most expensive condition at $64,688 average billing — over **23x more** than Flu ($2,744). While Alzheimer's has the longest average stay (54.4 days), Cancer drives the highest billing due to treatment cost intensity.

### Summary

| Research Question | Key Insight |
|---|---|
| Patient distribution | Even across all 4 hospitals; Seniors are the largest group |
| Medical conditions | Uniform prevalence (~12.5% each); consistent mix across hospitals |
| Admission patterns | 36% Emergency; peak admissions in July–Aug |
| Billing & financial | Cancer = highest cost ($64K avg); Alzheimer's = longest stay (54 days) |

---

## Troubleshooting

### `bruin validate` shows 0 assets

Bruin looks for `.bruin.yml` by traversing **up** from the current directory to the repo root. Make sure:
- You are running `bruin validate .` from inside the `bruin/` folder
- `/workspaces/healthcare/.bruin.yml` (root level) has valid GCP connections — **not** `connections: {}`

### `connection not found` error

Your `.bruin.yml` must define connections named exactly `bigquery` and `gcp-default` (matching `pipeline.yml`'s `default_connections`).

### Terraform `QUOTA_PROJECT_ID` error

```bash
gcloud auth application-default set-quota-project your-gcp-project-id
```

### Python `ModuleNotFoundError` in Bruin assets

Bruin runs Python assets as modules. Ensure `__init__.py` files exist in:
- `bruin/`
- `bruin/assets/`
- `bruin/assets/extract/`

### Kaggle download fails

Make sure `KAGGLE_USERNAME` and `KAGGLE_KEY` are exported, or place `kaggle.json` at `~/.kaggle/kaggle.json`.

---

## Dashboard

View the interactive Looker Studio dashboard: [Healthcare Admissions Analytics](https://lookerstudio.google.com/reporting/befac3fb-12ae-4d7b-ae74-a18f4f0825dc)
