{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    transaction_id,
    worker_id,
    UPPER(country_code) AS country_code,
    payment_date,
    scheduled_date,
    amount,
    TRIM(compliance_status) AS compliance_status
FROM {{ source('deel_data', 'raw_payroll_transactions') }}
WHERE transaction_id IS NOT NULL
  AND amount IS NOT NULL