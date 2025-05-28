{{ config(
    materialized='table',
    schema='intermediate'
) }}

WITH staged AS (
    SELECT
        regulation_id,
        country_id,
        rule_type,
        description,
        COALESCE(effective_date, '1900-01-01')::DATE AS effective_date,
        end_date,
        is_active,
        tax_rate,
        compliance_category
    FROM {{ ref('stg_deel_regulations') }}
),
scd_logic AS (
    SELECT
        regulation_id,
        country_id,
        rule_type,
        description,
        effective_date,
        COALESCE(
            LEAD(effective_date) OVER (PARTITION BY regulation_id ORDER BY effective_date),
            '9999-12-31'
        )::DATE AS end_date,
        is_active,
        tax_rate,
        compliance_category,
        {{ dbt_utils.generate_surrogate_key(['regulation_id', 'effective_date']) }} AS regulation_surrogate_key
    FROM staged
    WHERE effective_date IS NOT NULL
)
SELECT * FROM scd_logic