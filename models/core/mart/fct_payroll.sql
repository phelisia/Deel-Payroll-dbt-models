{{ config(materialized='view', schema='analytics') }}

WITH base AS (
    SELECT * FROM {{ ref('int_payroll_joined') }}
),

monthly_country_kpis AS (
    SELECT
        payment_month,
        country_code,
        NULL AS worker_type,
        COUNT(DISTINCT worker_id) AS num_workers_paid,
        SUM(amount) AS total_payout,
        AVG(amount) AS avg_payout
    FROM base
    GROUP BY 1, 2
),

user_type_kpis AS (
    SELECT
        CAST(NULL AS DATE) AS payment_month,
        CAST(NULL AS TEXT) AS country_code,
        worker_type,
        COUNT(DISTINCT worker_id) AS num_workers_paid,
        SUM(amount) AS total_payout,
        AVG(amount) AS avg_payout
    FROM base
    GROUP BY 3
)

SELECT * FROM monthly_country_kpis
UNION ALL
SELECT * FROM user_type_kpis
