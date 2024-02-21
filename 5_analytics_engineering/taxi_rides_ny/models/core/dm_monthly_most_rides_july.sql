{{ config(materialized="table") }}

with
    green_trips as (
        select service_type, count(*) as total_trips
        from {{ ref("fact_trips") }}
        where
            extract(year from pickup_datetime) = 2019
            and extract(month from pickup_datetime) = 7
            and service_type = 'Green'
        group by 1
    ),

    yellow_trips as (
        select service_type, count(*) as total_trips
        from {{ ref("fact_trips") }}
        where
            extract(year from pickup_datetime) = 2019
            and extract(month from pickup_datetime) = 7
            and service_type = 'Yellow'
        group by 1
    ),

    fhv_trips as (
        select service_type, count(*) as total_trips
        from {{ ref("fact_trips_fhv") }}
        where
            extract(year from pickup_datetime) = 2019
            and extract(month from pickup_datetime) = 7
            and service_type = 'fhv'
        group by 1
    ),

    all_trips as (
        select *
        from green_trips
        union all
        select *
        from yellow_trips
        union all
        select *
        from fhv_trips
    )

select *
from all_trips
order by 2 desc
