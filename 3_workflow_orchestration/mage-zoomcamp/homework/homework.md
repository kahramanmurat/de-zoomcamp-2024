## Week 2 Homework

> In case you don't get one option exactly, select the closest one 

For the homework, we'll be working with the _green_ taxi dataset located here:

`https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green/download`

### Assignment

The goal will be to construct an ETL pipeline that loads the data, performs some transformations, and writes the data to a database (and Google Cloud!).

- Create a new pipeline, call it `green_taxi_etl`
- Add a data loader block and use Pandas to read data for the final quarter of 2020 (months `10`, `11`, `12`).
  - You can use the same datatypes and date parsing methods shown in the course.
  - `BONUS`: load the final three months using a for loop and `pd.concat`
- Add a transformer block and perform the following:
  - Remove rows where the passenger count is equal to 0 _or_ the trip distance is equal to zero.
  - Create a new column `lpep_pickup_date` by converting `lpep_pickup_datetime` to a date.
  - Rename columns in Camel Case to Snake Case, e.g. `VendorID` to `vendor_id`.
  - Add three assertions:
    - `vendor_id` is one of the existing values in the column (currently)
    - `passenger_count` is greater than 0
    - `trip_distance` is greater than 0
- Using a Postgres data exporter (SQL or Python), write the dataset to a table called `green_taxi` in a schema `mage`. Replace the table if it already exists.
- Write your data as Parquet files to a bucket in GCP, partioned by `lpep_pickup_date`. Use the `pyarrow` library!
- Schedule your pipeline to run daily at 5AM UTC.

### Questions

## Question 1. Data Loading

Once the dataset is loaded, what's the shape of the data?

* 266,855 rows x 20 columns
* 544,898 rows x 18 columns
* 544,898 rows x 20 columns
* 133,744 rows x 20 columns

>Answer: 266,855 rows x 20 columns

Python Code for Mage @dataexport block

```import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """

    urls = [
        "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-10.csv.gz",
        "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-11.csv.gz",
        "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-12.csv.gz"
    ]

    taxi_dtypes={'VendorID' : 'Int64',
    'store_and_fwd_flag' : 'str',
    'RatecodeID' : 'Int64',
    'PULocationID' : 'Int64',
    'DOLocationID' : 'Int64',
    'passenger_count' : 'Int64',
    'trip_distance' : 'float64',
    'fare_amount' : 'float64',
    'extra' : 'float64',
    'mta_tax' : 'float64',
    'tip_amount' : 'float64',
    'tolls_amount' : 'float64',
    'ehail_fee' : 'float64',
    'improvement_surcharge' : 'float64',
    'total_amount' : 'float64',
    'payment_type' : 'float64',
    'trip_type' : 'float64',
    'congestion_surcharge' : 'float64'}

    parse_dates = ['lpep_pickup_datetime', 'lpep_dropoff_datetime']

    dfs=[]

    for url in urls:

        df=pd.read_csv(url, sep=',',compression="gzip",dtype=taxi_dtypes, parse_dates=parse_dates)

        dfs.append(df)
    
    final_df = pd.concat(dfs, ignore_index=True)

    return final_df

@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'

```

## Question 2. Data Transformation

Upon filtering the dataset where the passenger count is greater than 0 _and_ the trip distance is greater than zero, how many rows are left?

* 544,897 rows
* 266,855 rows
* 139,370 rows
* 266,856 rows

>Answer: 139,370 rows

```
if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):

    # Print information about rows with zero passengers
    zero_passenger_count = data['passenger_count'].isin([0]).sum()
    zero_trip_distance = data['trip_distance'].isin([0]).sum()

    print(f"Preprocessing: rows with zero passengers: {zero_passenger_count}")
    print(f"Preprocessing: rows with zero trip distance: {zero_trip_distance}")


    # Remove rows where passenger_count or trip_distance is equal to 0
    data = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)]

    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    data.columns=data.columns.str.replace(' ','_').str.lower()
    
    return data


@test
def test_output(output, *args) -> None:
    # Get unique values from 'vendor_id' column
    unique_vendor_ids = output['vendorid'].unique()

    assert set(output['vendorid']).issubset(unique_vendor_ids), "vendorid is not one of the existing values."
    assert (output['passenger_count'] > 0).all(), "passenger_count should be greater than 0."
    assert (output['trip_distance'] > 0).all(), "trip_distance should be greater than 0."
```

## Question 3. Data Transformation

Which of the following creates a new column `lpep_pickup_date` by converting `lpep_pickup_datetime` to a date?

* `data = data['lpep_pickup_datetime'].date`
* `data('lpep_pickup_date') = data['lpep_pickup_datetime'].date`
* `data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date`
* `data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt().date()`

>Answer:
```
data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date
```

## Question 4. Data Transformation

What are the existing values of `VendorID` in the dataset?

* 1, 2, or 3
* 1 or 2
* 1, 2, 3, 4
* 1

>Answer: 1 or 2

BigQuery SQL query:

```
SELECT  DISTINCT(vendorid) FROM `ny-taxi-2024.ny_taxi_data.green_taxi`

```

## Question 5. Data Transformation

How many columns need to be renamed to snake case?

* 3
* 6
* 2
* 4

>Answer: 4

```
VendorID
RatecodeID
PULocationID
DOLocationID
```

## Question 6. Data Exporting

Once exported, how many partitions (folders) are present in Google Cloud?

* 96
* 56
* 67
* 108

>Answer: 96

