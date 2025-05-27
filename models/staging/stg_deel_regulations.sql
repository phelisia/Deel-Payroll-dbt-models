{{ config(
    materialized='view'
) }}

with

source as (
    select * from {{ source('deel_data', 'regulations') }}
),

renamed as (
    select
        -- ids
        REGEXP_REPLACE(REGEXP_REPLACE(regulation_id, '^TAX|^REG', ''), '^0*', '')::VARCHAR as regulation_id,

        -- strings
        country_id::VARCHAR as country_id,
        description::VARCHAR as description,
        rule_type::VARCHAR as rule_type,
        tax_rate ,
        compliance_category,

        -- dates
        effective_date::DATE as effective_date,
        coalesce(end_date, '9999-12-31')::DATE as end_date,

        -- booleans
        case
            when end_date is null or end_date > current_date then true
            else false
        end as is_active,

        -- data quality
        case
            when regulation_id is null or regulation_id = '' then true
            else false
        end as is_filtered

    from source
)

select * from renamed where not is_filtered