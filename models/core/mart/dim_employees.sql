{{ config(
    materialized='incremental',
    unique_key='employee_surrogate_key',
    partition_by={'field': 'effective_date', 'data_type': 'date'}
) }}

with

source as (
    select
        employee_surrogate_key,
        employee_id,
        employee_name,
        contract_type,
        effective_date,
        end_date,
        is_active_employee
    from {{ ref('int_employees_scd') }}
),

filtered as (
    select
        employee_surrogate_key,
        employee_id,
        employee_name,
        contract_type,
        effective_date,
        end_date,
        is_active_employee
    from source
    {% if is_incremental() %}
    where effective_date > (select coalesce(max(effective_date), '1900-01-01') from {{ this }})
    {% endif %}
)

select * from filtered 
  