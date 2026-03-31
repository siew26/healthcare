/* @bruin

name: healthcare_raw.validate_raw_data
type: bq.sql
materialization:
  type: table

depends:
  - load_gcs_to_bq

@bruin */

SELECT 
  COUNT(*) as total_rows,
  COUNT(DISTINCT `Name`) as unique_names,
  MIN(`Date of Admission`) as earliest_admission,
  MAX(`Date of Admission`) as latest_admission,
  CURRENT_TIMESTAMP() as loaded_at
FROM `healthcare-dataset-491812.healthcare_raw.load_raw`
