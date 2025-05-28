{{ config(
    materialized='table',
    schema='intermediate'
) }}

with

gaps as (
    select
        employee_id,
        end_date,
        effective_date as next_effective_date,
        effective_date - end_date - interval '1 day' as gap_days
    from {{ ref('int_employees_scd') }}
    where effective_date > (
        select max(end_date)
        from {{ ref('int_employees_scd') }} s2
        where s2.employee_id = {{ ref('int_employees_scd') }}.employee_id
        and s2.end_date < {{ ref('int_employees_scd') }}.effective_date
    )
    and effective_date != (
        select min(effective_date)
        from {{ ref('int_employees_scd') }} s3
        where s3.employee_id = {{ ref('int_employees_scd') }}.employee_id
    )
)

select
    employee_id,
    end_date,
    next_effective_date,
    gap_days
from gaps
where gap_days > interval '0 days'