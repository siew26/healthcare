/* @bruin

name: healthcare_mart.fact_hospital_admissions
type: bq.sql
materialization:
  type: table
  strategy: create+replace
  cluster_by: [hospital_name, medical_condition, admission_date]

depends:
  - healthcare_staging.stg_admissions

@bruin */

SELECT
  admission_id,
  patient_name,
  patient_age,
  patient_gender,
  admission_date,
  discharge_date,
  actual_length_of_stay,
  reported_length_of_stay,
  medical_condition,
  doctor_name,
  hospital_name,
  admission_type,
  insurance_provider,
  medication,
  test_results,
  billing_amount,
  room_number,
  EXTRACT(YEAR FROM admission_date) AS admission_year,
  EXTRACT(MONTH FROM admission_date) AS admission_month,
  EXTRACT(QUARTER FROM admission_date) AS admission_quarter,
  CASE
    WHEN patient_age < 18 THEN 'Pediatric'
    WHEN patient_age BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN patient_age BETWEEN 36 AND 55 THEN 'Middle Age'
    ELSE 'Senior'
  END AS age_group,
  loaded_at
FROM `healthcare-dataset-491812.healthcare_staging.stg_admissions`
where EXTRACT(YEAR FROM admission_date) between 2020 and 2023
