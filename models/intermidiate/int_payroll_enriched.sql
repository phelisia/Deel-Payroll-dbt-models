{{ config(materialized='view', schema='intermediate') }}

with payroll as (
    select * from {{ ref('stg_payroll_transactions') }}
),
workers as (
    select * from {{ ref('stg_workers') }}
),
rules as (
    select * from {{ ref('stg_compliance_rules') }}
)

select
    p.transaction_id,
    p.worker_id,
    p.country_code,
    p.amount,
    p.payment_date,
    w.worker_type,
    r.min_wage,
    case
        when p.amount >= r.min_wage then 'COMPLIANT'
        else 'NON-COMPLIANT'
    end as compliance_status
from payroll p
left join workers w using (worker_id, country_code)
left join rules r using (country_code)
