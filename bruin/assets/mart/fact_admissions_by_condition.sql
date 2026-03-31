/* @bruin

name: healthcare_mart.fact_admissions_by_condition
type: bq.sql
materialization:
  type: table
  strategy: create+replace
  cluster_by: [admission_year, medical_condition]

depends:
  - healthcare_mart.fact_hospital_admissions

@bruin */

SELECT
  admission_year,
  admission_month,
  medical_condition,
  COUNT(*) AS admission_count,
  COUNT(DISTINCT patient_name) AS unique_patients,
  ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
  ROUND(SUM(billing_amount), 2) AS total_billing_amount,
  ROUND(AVG(actual_length_of_stay), 2) AS avg_length_of_stay,
  ROUND(AVG(patient_age), 1) AS avg_patient_age,
  ROUND(100.0 * COUNTIF(patient_gender = 'M') / COUNT(*), 1) AS pct_male,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_mart.fact_hospital_admissions`
GROUP BY admission_year, admission_month, medical_condition
