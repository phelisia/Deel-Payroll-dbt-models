{{ config(materialized='view', schema='intermediate') }}

WITH workers AS (
    SELECT * FROM {{ ref('stg_workers') }}
),
transactions AS (
    SELECT * FROM {{ ref('stg_payroll_transactions') }}
)

SELECT
    t.transaction_id,
    t.payment_date,
    t.payment_month,
    t.amount,
    w.worker_id,
    w.country_code,
    w.worker_type
FROM transactions t
JOIN workers w
  ON t.worker_id = w.worker_id
