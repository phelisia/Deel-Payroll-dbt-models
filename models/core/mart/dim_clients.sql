{{ config(
    materialized='table',
    unique_key='client_id'
) }}

with source as (

select
    client_id,
    company_name,
    industry,
    country_id
from {{ ref('int_deel_clients') }}
)

select * from source