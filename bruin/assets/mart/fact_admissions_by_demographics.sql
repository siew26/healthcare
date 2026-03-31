/* @bruin

name: healthcare_mart.fact_admissions_by_demographics
type: bq.sql
materialization:
  type: table
  strategy: create+replace
  cluster_by: [age_group, patient_gender]

depends:
  - healthcare_mart.fact_hospital_admissions

@bruin */

SELECT
  age_group,
  patient_gender,
  COUNT(*) AS admission_count,
  COUNT(DISTINCT patient_name) AS unique_patients,
  ROUND(AVG(patient_age), 1) AS avg_patient_age,
  ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
  ROUND(SUM(billing_amount), 2) AS total_billing_amount,
  ROUND(AVG(actual_length_of_stay), 2) AS avg_length_of_stay,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_mart.fact_hospital_admissions`
GROUP BY age_group, patient_gender
