{{ config(
    materialized='table',
    schema ='analytics'
) }}

with

source as (
    select
       audit_id,
       employee_id,
       regulation_id,
       check_date,
       result,
       violation_details
    from {{ ref('int_compliance_events') }}
)

select * from  source