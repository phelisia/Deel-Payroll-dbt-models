{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    UPPER(country_code) AS country_code,
    rule_id,
    min_wage
FROM {{ source('deel_data', 'raw_compliance_rules') }}
WHERE country_code IS NOT NULL
  AND min_wage > 0