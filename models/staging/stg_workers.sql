{{ config(
    materialized='view',
    schema='staging'
) }}

with main as (

SELECT
    worker_id,
    worker_type,
    country_code
FROM {{ source('deel_data', 'raw_workers') }}
WHERE worker_id IS NOT NULL
),

renamed as (

  SELECT
    worker_id,
    TRIM(worker_type) AS worker_type,
    UPPER(country_code) AS country_code
FROM main

)
select * from renamed