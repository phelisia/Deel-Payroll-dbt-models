{{ config(
    materialized='table',
    unique_key='payment_id',
    schema='analytics'
) }}

WITH payroll AS (
    SELECT
        payment_id,
         CAST(employee_id AS VARCHAR) AS employee_id,
        CAST(client_id AS VARCHAR) AS client_id,
        CAST(country_id AS VARCHAR) AS country_id,
        CAST(tax_rule_id AS VARCHAR) AS tax_rule_id,
        gross_pay,
        tax_amount,
        net_pay,
        currency,
        payment_date,
        status,
        compliance_status,
        processing_time_seconds
    FROM {{ ref('int_payroll') }}
),
joined AS (
    SELECT
        p.payment_id,
        p.employee_id,
        p.client_id,
        dc.client_id AS dim_client_id,
        p.tax_rule_id,
        p.country_id,
        de.employee_surrogate_key,
        COALESCE(de.employee_name, 'Unknown Employee') AS employee_name,
        de.contract_type,
        COALESCE(tr.regulation_surrogate_key, 'Unknown') AS tax_rule_surrogate_key,
        p.gross_pay,
        p.tax_amount,
        p.net_pay,
        p.currency,
        p.payment_date,
        p.status,
        p.compliance_status,
        p.processing_time_seconds,
        CASE WHEN de.employee_surrogate_key IS NOT NULL THEN TRUE ELSE FALSE END AS employee_matched,
        CASE WHEN tr.regulation_surrogate_key IS NOT NULL THEN TRUE ELSE FALSE END AS tax_rule_matched,
        CASE WHEN dc.client_id IS NOT NULL THEN TRUE ELSE FALSE END AS client_matched
    FROM payroll p
    LEFT JOIN {{ ref('dim_employees') }} de
        ON p.employee_id = de.employee_id
    LEFT JOIN {{ ref('dim_tax_rule') }} tr
        ON p.tax_rule_id = tr.regulation_id
    LEFT JOIN {{ ref('dim_clients') }} dc
        ON p.client_id = dc.client_id
)
SELECT * FROM joined