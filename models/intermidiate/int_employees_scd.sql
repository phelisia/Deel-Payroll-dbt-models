{{ config(
    materialized='table'
) }}

with

staged as (
    select
        employee_id,
        employee_name,
        contract_type,
        updated_at as effective_date
    from {{ ref('stg_employees') }}
),

scd_logic as (
    select
        employee_id,
        employee_name,
        contract_type,
        effective_date,
        coalesce(
            lead(effective_date) over (partition by employee_id order by effective_date),
            '9999-12-31'
        )::DATE as end_date,
        case
            when row_number() over (partition by employee_id order by effective_date desc) = 1
            then true
            else false
        end as is_active_employee,
        {{ dbt_utils.generate_surrogate_key(['employee_id', 'effective_date']) }} as employee_surrogate_key
    from staged
)

select * from scd_logic