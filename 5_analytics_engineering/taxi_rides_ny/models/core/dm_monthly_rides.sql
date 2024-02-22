{{ config(materialized="table") }}

with
    green_trips as (
        select
            service_type,
            extract(year from pickup_datetime) as trip_year,
            extract(month from pickup_datetime) as trip_month,
            count(*) as total_trips
        from {{ ref("fact_trips") }}
        where
            extract(year from pickup_datetime) between 2019 and 2020
            and service_type = 'Green'
        group by 1, 2, 3
    ),

    yellow_trips as (
        select
            service_type,
            extract(year from pickup_datetime) as trip_year,
            extract(month from pickup_datetime) as trip_month,
            count(*) as total_trips
        from {{ ref("fact_trips") }}
        where
            extract(year from pickup_datetime) between 2019 and 2020
            and service_type = 'Yellow'
        group by 1, 2, 3
    ),

    fhv_trips as (
        select
            service_type,
            extract(year from pickup_datetime) as trip_year,
            extract(month from pickup_datetime) as trip_month,
            count(*) as total_trips
        from {{ ref("fact_trips_fhv") }}
        where
            extract(year from pickup_datetime) between 2019 and 2020
            and service_type = 'fhv'
        group by 1, 2, 3
    ),

    all_trips as (
        select concat(trip_year, '-', trip_month) as year_month, *
        from green_trips
        union all
        select concat(trip_year, '-', trip_month) as year_month, *
        from yellow_trips
        union all
        select concat(trip_year, '-', trip_month) as year_month, *
        from fhv_trips
    )

select *
from all_trips
order by 2, 3 desc
