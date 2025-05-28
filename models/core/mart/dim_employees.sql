{{ config(
    materialized='incremental',
    unique_key='employee_surrogate_key',
    partition_by={'field': 'effective_date', 'data_type': 'date'},
    schema = 'analytics'
) }}

select
    employee_surrogate_key,
    employee_id,
    employee_name,
    contract_type,
    effective_date,
    end_date,
    is_active_employee,
    case
        when contract_type = 'full-time' then true
        else false
    end as full_time_flag
from {{ ref('int_employees_scd') }} 