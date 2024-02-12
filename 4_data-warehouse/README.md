gsutil cp -r green_tripdata_2022 gs://ny-taxi-2024-green_taxi-bucket/
url
['https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-01.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-02.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-03.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-04.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-05.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-06.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-07.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-08.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-09.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-10.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-11.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-12.parquet']

CREATE OR REPLACE EXTERNAL TABLE `ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://ny-taxi-2024-green_taxi-bucket/green_tripdata_2022/green_tripdata_2022-*.parquet']
);

-- Check green trip data
SELECT * FROM ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022 limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_non_partitoned AS SELECT * FROM ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022;

-- Create a partitioned table from external table
CREATE OR REPLACE TABLE ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned
PARTITION BY
  DATE(lpep_pickup_datetime) AS
SELECT * FROM ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022;

-- Impact of partition
-- Scanning 12.82MB of data
SELECT DISTINCT(VendorID)
FROM ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_non_partitoned 
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- Scanning 1.12 MB of DATA
SELECT DISTINCT(VendorID)
FROM ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- Let's look into the partitons
SELECT table_name, partition_id, total_rows
FROM `ny-taxi-2024.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'green_tripdata_partitoned'
ORDER BY total_rows DESC;


-- Creating a partition and cluster table
CREATE OR REPLACE TABLE ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned_clustered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022;


-- Query scans 12.82MB
SELECT count(*) as trips
FROM ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-01-01' AND '2022-12-31'
  AND VendorID=1;

-- Query scans 864.5 MB
SELECT count(*) as trips
FROM ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned_clustered
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-01-01' AND '2022-12-31'
  AND VendorID=1;


-- SELECT THE COLUMNS INTERESTED FOR YOU
SELECT passenger_count, trip_distance, PULocationID, DOLocationID, payment_type, fare_amount, tolls_amount, tip_amount
FROM `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned` WHERE fare_amount != 0;

-- CREATE A ML TABLE WITH APPROPRIATE TYPE
CREATE OR REPLACE TABLE `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml` (
`passenger_count` INTEGER,
`trip_distance` FLOAT64,
`PULocationID` STRING,
`DOLocationID` STRING,
`payment_type` STRING,
`fare_amount` FLOAT64,
`tolls_amount` FLOAT64,
`tip_amount` FLOAT64
) AS (
SELECT passenger_count, trip_distance, cast(PULocationID AS STRING), CAST(DOLocationID AS STRING),
CAST(payment_type AS STRING), fare_amount, tolls_amount, tip_amount
FROM `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_partitoned` WHERE fare_amount != 0
);


-- CREATE MODEL WITH DEFAULT SETTING
CREATE OR REPLACE MODEL `ny-taxi-2024.bq_green_taxi_dataset.tip_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT') AS
SELECT
*
FROM
`ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL;

-- CHECK FEATURES
SELECT * FROM ML.FEATURE_INFO(MODEL `ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`);

-- EVALUATE THE MODEL
SELECT
*
FROM
ML.EVALUATE(MODEL `ny-taxi-2024.bq_green_taxi_dataset.tip_model`,
(
SELECT
*
FROM
`ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));


-- PREDICT THE MODEL
SELECT
*
FROM
ML.PREDICT(MODEL `ny-taxi-2024.bq_green_taxi_dataset.tip_model`,
(
SELECT
*
FROM
`ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));


-- PREDICT AND EXPLAIN
SELECT
*
FROM
ML.EXPLAIN_PREDICT(MODEL `ny-taxi-2024.bq_green_taxi_dataset.tip_model`,
(
SELECT
*
FROM
`ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
), STRUCT(3 as top_k_features));


-- HYPER PARAM TUNNING
CREATE OR REPLACE MODEL `ny-taxi-2024.bq_green_taxi_dataset.tip_hyperparam_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT',
num_trials=5,
max_parallel_trials=2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10])) AS
SELECT
*
FROM
`ny-taxi-2024.bq_green_taxi_dataset.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL;


gcloud auth login
bq --project_id ny-taxi-2024 extract -m bq_green_taxi_dataset.tip_model gs://ny-taxi-2024-green_taxi-bucket/tip_model
mkdir /tmp/model
gsutil cp -r gs://ny-taxi-2024-green_taxi-bucket/tip_model /tmp/model
mkdir -p serving_dir/tip_model/1
cp -r /tmp/model/tip_model/* serving_dir/tip_model/1
docker pull tensorflow/serving
docker run -p 8501:8501 --mount type=bind,source=pwd/serving_dir/tip_model,target= /models/tip_model -e MODEL_NAME=tip_model -t tensorflow/serving &