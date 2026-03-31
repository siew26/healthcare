/* @bruin

name: healthcare_mart.dim_medical_conditions
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - healthcare_staging.stg_admissions

@bruin */

SELECT
  ROW_NUMBER() OVER (ORDER BY medical_condition) AS condition_id,
  medical_condition AS condition_name,
  COUNT(*) AS admission_count,
  COUNT(DISTINCT patient_name) AS unique_patients,
  ROUND(AVG(actual_length_of_stay), 2) AS avg_length_of_stay,
  ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
  MIN(admission_date) AS first_admission_date,
  MAX(admission_date) AS last_admission_date,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_staging.stg_admissions`
GROUP BY medical_condition
