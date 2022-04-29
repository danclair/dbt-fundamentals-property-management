with tenants as (
    select * from {{ ref('dim_tenants') }}
),
leases as (
    select * from {{ ref('stg_leases') }}
),
units as (
    select * from {{ ref('stg_units') }}
),
transactions as (
    select * from {{ ref('stg_transactions') }}
),
tenant_unit_lease as (
    select
        tenants.tenant_full_name,
        tenants.lease_id,
        leases.unit_id,
        units.rent
    from tenants
    left join leases using (tenants.lease_id)
    left join units using (leases.unit_id)
),
final as (
    select
        transactions.transaction_id,
        transactions.type,
        transactions.amount,
        transactions.payer,
        transactions.payee,
        transactions.created_at,
        tenant_unit_lease.unit_id
    from transactions
    left join tenant_unit_lease on transactions.payer = tenant_unit_lease.tenant_full_name
    where transactions.type = 'charge'
    and transactions.amount = tenant_unit_lease.rent
)
select * from final