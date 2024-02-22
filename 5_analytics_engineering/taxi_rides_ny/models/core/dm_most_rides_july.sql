{{ config(materialized="table") }}


select service_type, total_trips
from {{ ref("dm_monthly_rides") }}
where trip_year = 2019 and trip_month = 9
order by 2 desc limit 1
