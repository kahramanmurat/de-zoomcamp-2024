import pandas as pd
import requests
import re
import pyarrow.parquet as pq
from io import BytesIO

def read_parquet_from_url(url):
    response = requests.get(url)
    with BytesIO(response.content) as f:
        table = pq.read_table(f)
    return table.to_pandas()

# Function to get URLs based on pattern
def get_urls_by_pattern(pattern):
    response = requests.get("https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page")
    urls = re.findall(r'href=[\'"]?([^\'" >]+)', response.text)
    matching_urls = [url for url in urls if pattern in url]
    return matching_urls

patterns = ['yellow_tripdata_2019', 'yellow_tripdata_2020']

# Dictionary to store dataframes
dataframes = []

# Read Parquet files for each pattern
for pattern in patterns:
    urls = get_urls_by_pattern(pattern)
    for url in urls:
        df = read_parquet_from_url(url)
        dataframes.append(df)

# Merge dataframes into one
merged_df = pd.concat(dataframes, ignore_index=True)
print(merged_df.head())