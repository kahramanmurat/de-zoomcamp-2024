import pandas as pd
import gcsfs

base_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2020-{}.csv.gz"
months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

taxi_dtypes = {
    'dispatching_base_num': 'str',
    'PUlocationID': 'Int64',
    'DOlocationID': 'Int64',
    'SR_Flag': 'str',
    'Affiliated_base_number': 'str'}

parse_dates = ['pickup_datetime', 'dropOff_datetime']

for month in months:
    url = base_url.format(month)
    df = pd.read_csv(url, sep=',', compression="gzip", dtype=taxi_dtypes, parse_dates=parse_dates)
    
    # Define GCS path for each file
    gcs_path = f'gs://ny-taxi-2024-taxi-bucket/fhv_tripdata/fhv_tripdata_2020_{month}.csv'

    # Create GCSFileSystem object
    gcs_filesystem = gcsfs.GCSFileSystem()

    # Export dataframe to GCS
    with gcs_filesystem.open(gcs_path, 'w') as gcs_file:
        df.to_csv(gcs_file, index=False)

    print(f"Exported dataframe for month {month} to GCS:", gcs_path)
