{{ config(
    materialized='table',
    schema ='intermediate'
) }}

with

staged as (
    select
        client_id,
        company_name,
        industry,
        country_id
    from {{ ref('stg_deel_clients') }}
),

cleaned as (
    select
        client_id,
        company_name,
        coalesce(industry, 'Unknown') as industry,
        country_id
    from staged
    where client_id is not null
)

select * from cleaned