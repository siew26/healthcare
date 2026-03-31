/* @bruin

name: healthcare_staging.stg_admissions
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - load_gcs_to_bq

@bruin */

SELECT
  ROW_NUMBER() OVER (ORDER BY `Date of Admission`, `Name`) AS admission_id,
  `Name` AS patient_name,
  `Date of Admission` AS admission_date,
  `Discharge Date` AS discharge_date,
  CAST(DATETIME_DIFF(CAST(`Discharge Date` AS DATETIME), CAST(`Date of Admission` AS DATETIME), DAY) AS INT64) AS actual_length_of_stay,
  `Length of Stay` AS reported_length_of_stay,
  `Medical Condition` AS medical_condition,
  Doctor AS doctor_name,
  Hospital AS hospital_name,
  `Admission Type` AS admission_type,
  `Insurance Provider` AS insurance_provider,
  Medication AS medication,
  `Test Results` AS test_results,
  CAST(`Billing Amount` AS FLOAT64) AS billing_amount,
  `Room Number` AS room_number,
  Age AS patient_age,
  Gender AS patient_gender,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `healthcare-dataset-491812.healthcare_raw.load_raw`
WHERE `Date of Admission` IS NOT NULL
  AND `Name` IS NOT NULL
  AND Hospital IS NOT NULL
