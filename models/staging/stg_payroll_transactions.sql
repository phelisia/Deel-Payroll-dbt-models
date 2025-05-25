{{ config(
    materialized='view',
    schema='staging'
) }}

with main as (
    SELECT
        transaction_id,
        worker_id,
        country_code,
        payment_date,
        scheduled_date,
        amount,
        compliance_status
    FROM {{ source('deel_data', 'raw_payroll_transactions') }}
    WHERE transaction_id IS NOT NULL
      AND amount IS NOT NULL
),

renamed as (
    SELECT
        transaction_id,
        worker_id,
        UPPER(country_code) AS country_code,
        payment_date :: date,
        scheduled_date :: date,
        DATE_TRUNC('month', payment_date)::DATE AS payment_month,
        amount,
        TRIM(compliance_status) AS compliance_status
    FROM main
)

SELECT
    *
FROM renamed
