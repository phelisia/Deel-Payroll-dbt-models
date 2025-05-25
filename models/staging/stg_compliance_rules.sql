{{ config(
    materialized='view',
    schema='staging'
) }}

with main as (
    select
        country_code,
        rule_id,
        min_wage
    from {{ source('deel_data', 'raw_compliance_rules') }}
    where country_code is not null
      and min_wage > 0
),

renamed as (
    select
        upper(country_code) as country_code,
        rule_id,
        min_wage
    from main
)

select * from renamed
