/* @bruin

name: healthcare_mart.dim_hospitals
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - healthcare_staging.stg_admissions

@bruin */

SELECT
  ROW_NUMBER() OVER (ORDER BY hospital_name) AS hospital_id,
  hospital_name,
  COUNT(*) AS total_admissions,
  COUNT(DISTINCT patient_name) AS unique_patients,
  COUNT(DISTINCT doctor_name) AS doctor_count,
  ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
  ROUND(SUM(billing_amount), 2) AS total_billing_amount,
  MIN(admission_date) AS first_admission_date,
  MAX(admission_date) AS last_admission_date,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_staging.stg_admissions`
GROUP BY hospital_name
