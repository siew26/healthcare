/* @bruin

name: healthcare_staging.stg_patients
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - load_gcs_to_bq

@bruin */

SELECT
  ROW_NUMBER() OVER (ORDER BY `Name`) AS patient_id,
  `Name` AS patient_name,
  Age AS patient_age,
  Gender AS patient_gender,
  `Blood Type` AS blood_type,
  CURRENT_TIMESTAMP() AS loaded_at
FROM (
  SELECT DISTINCT
    `Name`,
    Age,
    Gender,
    `Blood Type`
  FROM `healthcare-dataset-491812.healthcare_raw.load_raw`
  WHERE `Name` IS NOT NULL AND Age IS NOT NULL
)
