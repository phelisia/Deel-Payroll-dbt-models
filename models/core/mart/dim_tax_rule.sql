{{ config(
    materialized='table',
    unique_key='regulation_surrogate_key',
    partition_by={'field': 'effective_date', 'data_type': 'date'},
    schema='analytics'
) }}

SELECT
    regulation_surrogate_key,
    regulation_id,
    country_id,
    rule_type,
    description,
    effective_date,
    end_date,
    is_active,
    tax_rate,
    compliance_category
FROM {{ ref('int_deel_regulations_scd') }}
WHERE effective_date IS NOT NULL