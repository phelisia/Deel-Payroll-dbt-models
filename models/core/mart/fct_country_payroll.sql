{{ config(materialized='table', schema='analytics') }}

with payroll as (
    select
        worker_id,
        country_code,
        payment_date,
        amount,
        compliance_status
    from {{ ref('int_payroll_enriched') }}
),

country_summary as (
    select
        country_code,
        count(distinct worker_id) as total_workers,
        count(*) as total_payments,
        round(sum(amount), 2) as total_payroll_cost,
        round(avg(amount), 2) as avg_monthly_salary,
        round(
            100.0 * sum(case when compliance_status = 'COMPLIANT' then 1 else 0 end) / count(*),
            2
        ) as compliance_rate_pct
    from payroll
    group by country_code
)

select * from country_summary
