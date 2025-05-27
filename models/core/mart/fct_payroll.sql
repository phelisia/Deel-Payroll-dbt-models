{{ config(
    materialized='table',
    unique_key='payment_id'
) }}

with

payroll as (
    select
        payment_id,
        employee_id,
        client_id,
        country_id,
        tax_rule_id,
        gross_pay,
        tax_amount,
        net_pay,
        currency,
        payment_date,
        status,
        compliance_status,
        processing_time_seconds
    from {{ ref('int_payroll') }}
),

joined as (
    select
        p.payment_id,
        e.employee_id,
        e.contract_type,
        de.employee_surrogate_key,
        p.client_id,
        dc.client_id as dim_client_id,
        p.country_id,
        tr.regulation_surrogate_key as tax_rule_surrogate_key,
        p.gross_pay,
        p.tax_amount,
        p.net_pay,
        p.currency,
        p.payment_date,
        p.status,
        p.compliance_status,
        p.processing_time_seconds
    from {{ ref('stg_employees') }} e
    left join payroll p
        on e.employee_id = p.employee_id
    left join {{ ref('dim_employees') }} de
        on e.employee_id = de.employee_id
        and (p.payment_date between de.effective_date and de.end_date or p.payment_date is null)
        and (de.is_active_employee = true or de.is_active_employee is null)
    left join {{ ref('dim_tax_rule') }} tr
        on p.tax_rule_id = tr.regulation_id
        and (p.payment_date between tr.effective_date and tr.end_date or p.payment_date is null)
        and (tr.is_active = true or tr.is_active is null)
    left join {{ ref('dim_clients') }} dc
        on p.client_id = dc.client_id
)

select * from joined