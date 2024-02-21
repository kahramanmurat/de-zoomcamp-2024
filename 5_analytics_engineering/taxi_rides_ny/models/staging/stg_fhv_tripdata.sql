{{
    config(
        materialized='view'
    )
}}
with 

source as (

    select * from {{ source('staging', 'fhv_tripdata') }}

),

renamed as (

    select
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        pulocationid,
        dolocationid,
        sr_flag,
        affiliated_base_number

    from source

    where EXTRACT(YEAR FROM pickup_datetime) = 2019
   

)

select * from renamed

-- dbt build --select stg_fhv_tripdata --vars '{'is_test_run': 'false'}'
   
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
