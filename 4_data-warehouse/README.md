gsutil cp -r green_tripdata_2022 gs://ny-taxi-2024-green_taxi-bucket/
url
['https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-01.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-02.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-03.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-04.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-05.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-06.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-07.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-08.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-09.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-10.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-11.parquet', 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-12.parquet']

CREATE OR REPLACE EXTERNAL TABLE `ny-taxi-2024.bq_green_taxi_dataset.external_green_tripdata_2022`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://ny-taxi-2024-green_taxi-bucket/green_tripdata_2022/green_tripdata_2022-*.parquet']
);