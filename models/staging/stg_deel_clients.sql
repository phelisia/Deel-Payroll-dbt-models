{{ config(
    materialized='view'
) }}

with

source as (
    select * from {{ source('deel_data', 'companies') }}
),

renamed as (
    select
        -- ids
        REGEXP_REPLACE(REGEXP_REPLACE(client_id, '^CLI', ''), '^0*', '')::VARCHAR as client_id,

        -- strings
        company_name::VARCHAR as company_name,
        country_id::VARCHAR as country_id,
        industry,

        -- data quality
        case
            when client_id is null or client_id = '' then true
            else false
        end as is_filtered

    from source
)

select * from renamed where not is_filtered