{{ config(
    materialized='table',
    schema='intermediate'
) }}

with

employees as (
    select
        employee_id,
        employee_name,
        contract_type,
        updated_at as effective_date,
        ROW_NUMBER() OVER (PARTITION BY employee_id, updated_at ORDER BY updated_at) as rn
    from {{ ref('stg_employees') }}
),

deduped_employees as (
    select
        employee_id,
        employee_name,
        contract_type,
        effective_date
    from employees
    where rn = 1
),

ranked as (
    select
        employee_id,
        employee_name,
        contract_type,
        effective_date,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY effective_date) as row_num,
        LEAD(effective_date) OVER (PARTITION BY employee_id ORDER BY effective_date) as next_effective_date,
        LAG(contract_type) OVER (PARTITION BY employee_id ORDER BY effective_date) as prev_contract_type,
        LAG(employee_name) OVER (PARTITION BY employee_id ORDER BY effective_date) as prev_employee_name
    from deduped_employees
),

scd as (
    select
        employee_id,
        employee_name,
        contract_type,
        effective_date,
        COALESCE(
            next_effective_date - INTERVAL '1 day',
            '9999-12-31'
        )::DATE as end_date,
        case
            when next_effective_date is null then true
            else false
        end as is_active_employee
    from ranked
    where row_num = 1
        or contract_type != prev_contract_type
        or employee_name != prev_employee_name
)

select
    ROW_NUMBER() OVER (ORDER BY employee_id, effective_date) as employee_surrogate_key,
    employee_id,
    employee_name,
    contract_type,
    effective_date,
    end_date,
    is_active_employee
from scd