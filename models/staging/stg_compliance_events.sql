{{ config(
    materialized='view'
) }}

with

source as (
    select * from {{ source('deel_data', 'compliance_events') }}
),

renamed as (
    select
        -- ids
        REGEXP_REPLACE(REGEXP_REPLACE(audit_id, '^AUD', ''), '^0*', '')::VARCHAR as audit_id,
        REGEXP_REPLACE(REGEXP_REPLACE(employee_id, '^EMP', ''), '^0*', '')::VARCHAR as employee_id,
        REGEXP_REPLACE(REGEXP_REPLACE(regulation_id, '^TAX|^REG', ''), '^0*', '')::VARCHAR as regulation_id,

        -- dates
        check_date::DATE as check_date,

        -- strings
        result::VARCHAR as result,
        coalesce(violation_details, 'No details') as violation_details,

        -- data quality
        case
            when audit_id is null or audit_id = '' then true
            else false
        end as is_filtered

    from source
)

select * from renamed where not is_filtered