{{ config(
    materialized='view',
    schema='staging'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'regulations') }}
),
renamed AS (
    SELECT
        -- IDs
        REGEXP_REPLACE(REGEXP_REPLACE(COALESCE(regulation_id, ''), '^TAX|^REG', ''), '^0*', '')::VARCHAR AS regulation_id,

        -- Strings
        country_id::VARCHAR AS country_id,
        description::VARCHAR AS description,
        rule_type::VARCHAR AS rule_type,
        tax_rate,
        compliance_category,

        -- Dates
        COALESCE(effective_date, '1900-01-01')::DATE AS effective_date,
        COALESCE(end_date, '9999-12-31')::DATE AS end_date,

        -- Booleans
        CASE
            WHEN end_date IS NULL OR end_date > CURRENT_DATE THEN TRUE
            ELSE FALSE
        END AS is_active,

        -- Data quality
        CASE
            WHEN regulation_id IS NULL OR regulation_id = '' THEN TRUE
            ELSE FALSE
        END AS is_filtered
    FROM source
)
SELECT * FROM renamed WHERE NOT is_filtered