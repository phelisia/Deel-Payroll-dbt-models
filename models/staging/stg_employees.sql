{{ config(
    materialized='view'
) }}

with

source as (
    select * from {{ source('deel_data', 'employees') }}
),

renamed as (
    select
        -- ids
        employee_id::VARCHAR as employee_id,

        -- strings
        first_name || ' ' || last_name as employee_name,
        contract_type::VARCHAR as contract_type,

        -- timestamps
        updated_at::timestamptz as updated_at,

        -- data quality
        case
            when employee_id is null then true
            else false
        end as is_filtered

    from source
)

select * from renamed where not is_filtered
