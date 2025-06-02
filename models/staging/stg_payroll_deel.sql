{{ config(
    materialized='view',
    schema = 'staging'
) }}

with

source as (
    select * from {{ source('raw', 'payroll') }}
),

renamed as (
    select
        -- ids
        REGEXP_REPLACE(REGEXP_REPLACE(payment_id, '^PAY', ''), '^0*', '')::VARCHAR as payment_id,
        REGEXP_REPLACE(REGEXP_REPLACE(employee_id, '^EMP', ''), '^0*', '')::VARCHAR as employee_id,
        REGEXP_REPLACE(REGEXP_REPLACE(client_id, '^CLI', ''), '^0*', '')::VARCHAR as client_id,
        REGEXP_REPLACE(REGEXP_REPLACE(tax_rule_id, '^TAX|^REG', ''), '^0*', '')::VARCHAR as tax_rule_id,

        -- numerics
        gross_pay as gross_pay_cents,
        gross_pay / 100.0 as gross_pay_dollars,
        tax_amount as tax_amount_cents,
        tax_amount / 100.0 as tax_amount_dollars,
        net_pay as net_pay_cents,
        net_pay / 100.0 as net_pay_dollars,

        -- strings
        currency::VARCHAR as currency,
        status::VARCHAR as status,
        compliance_status::VARCHAR as compliance_status,
        country_id,

        -- dates
        date_trunc('day', payment_date)::timestamptz as payment_date,

        -- timestamps
        started_at::timestamptz as started_at,
        completed_at::timestamptz as completed_at,

        -- booleans
        case
            when status = 'completed' then true
            else false
        end as is_completed_payment,

        -- data quality
        case
            when payment_id is null or payment_id = '' or gross_pay < 0 then true
            else false
        end as is_filtered

    from source
)

select * from renamed where not is_filtered