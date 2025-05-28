{{ config(
    materialized='table',
    schema = 'intermediate'
) }}

with

staged as (
    select
        payment_id,
        employee_id,
        client_id,
        country_id,
        tax_rule_id,
        gross_pay_cents,
        gross_pay_dollars,
        tax_amount_cents,
        tax_amount_dollars,
        net_pay_cents,
        net_pay_dollars,
        currency,
        payment_date,
        status,
        compliance_status,
        started_at,
        completed_at,
        is_completed_payment
    from {{ ref('stg_payroll_deel') }}
),

calculated as (
    select
        payment_id,
        employee_id,
        client_id,
        country_id,
        tax_rule_id,
        gross_pay_dollars as gross_pay,
        tax_amount_dollars as tax_amount,
        net_pay_dollars as net_pay,
        currency,
        payment_date,
        status,
        compliance_status,
        case
            when is_completed_payment then extract(epoch from (completed_at - started_at))
            else null
        end as processing_time_seconds
    from staged
    where payment_id is not null
)

select *
from calculated