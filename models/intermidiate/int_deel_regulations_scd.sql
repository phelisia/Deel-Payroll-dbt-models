{{ config(
    materialized='table'
) }}

with

staged as (
    select
        regulation_id,
        country_id,
        rule_type,
        description,
        effective_date,
        end_date,
        is_active,
        tax_rate,
        compliance_category
    from {{ ref('stg_deel_regulations') }}
),

scd_logic as (
    select
        regulation_id,
        country_id,
        rule_type,
        description,
        effective_date,
        coalesce(
            lead(effective_date) over (partition by regulation_id order by effective_date),
            '9999-12-31'
        )::DATE as end_date,
        is_active,
        tax_rate,
        compliance_category,
        {{ dbt_utils.generate_surrogate_key(['regulation_id', 'effective_date']) }} as regulation_surrogate_key
    from staged
)

select * from scd_logic