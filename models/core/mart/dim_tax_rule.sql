{{ config(
    materialized='incremental',
    unique_key='regulation_surrogate_key',
    partition_by={'field': 'effective_date', 'data_type': 'date'}
) }}

with

source as (
    select
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
    from {{ ref('int_deel_regulations_scd') }}
),

filtered as (
    select
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
    from source
    {% if is_incremental() %}
    where effective_date > (select coalesce(max(effective_date), '1900-01-01') from {{ this }})
    {% endif %}
)

select * from filtered