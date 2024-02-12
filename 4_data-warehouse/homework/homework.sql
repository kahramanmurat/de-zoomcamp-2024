--Question-1:
SELECT COUNT(*) FROM `ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022`;

--Question-2:
-- Query scans 6.41MB
SELECT COUNT(DISTINCT PULocationID)  FROM `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_non_partitoned`;

-- Query scans OB
SELECT COUNT(DISTINCT PULocationID) FROM `ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022`;

--Question-3:
SELECT COUNT(*) FROM `ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022` WHERE fare_amount=0;

--Question-4
-- Creating a partition and cluster table
CREATE OR REPLACE TABLE ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned_clustered_hw
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PULocationID
AS
SELECT * FROM ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022;

--Question-5
-- Query scans 12.82MB
SELECT DISTINCT PULocationID
FROM  ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_non_partitoned
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- Query scans 1.12Byte
SELECT DISTINCT PULocationID
FROM  ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned_clustered_hw
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

--Question-8
-- Query scans 114.11MB
SELECT *  FROM `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_non_partitoned`;





