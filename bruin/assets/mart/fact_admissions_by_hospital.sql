/* @bruin

name: healthcare_mart.fact_admissions_by_hospital
type: bq.sql
materialization:
  type: table
  strategy: create+replace
  cluster_by: [hospital_name]

depends:
  - healthcare_mart.fact_hospital_admissions

@bruin */

SELECT
  hospital_name,
  COUNT(*) AS total_admissions,
  COUNT(DISTINCT patient_name) AS unique_patients,
  COUNT(DISTINCT medical_condition) AS distinct_conditions,
  COUNT(DISTINCT doctor_name) AS doctor_count,
  COUNT(DISTINCT admission_year) AS years_of_data,
  ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
  ROUND(SUM(billing_amount), 2) AS total_billing_amount,
  ROUND(AVG(actual_length_of_stay), 2) AS avg_length_of_stay,
  COUNTIF(admission_type = 'Emergency') AS emergency_admission_count,
  COUNTIF(admission_type = 'Elective') AS elective_admission_count,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_mart.fact_hospital_admissions`
GROUP BY hospital_name
