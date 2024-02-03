from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from pandas import DataFrame
from os import path
import os

import pyarrow as pa
import pyarrow.parquet as pq


if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

os.environ['GOOGLE_APPLICATION_CREDENTIALS']='/home/src/ny-taxi-2024-cd6295f0f09b.json'


bucket_name = 'mage-zoomcamp-mk'
project_id = 'ny-taxi-2024'
table_name='nyc_taxi_data'

root_path=f'{bucket_name}/{table_name}'

@data_exporter
def export_data_to_google_cloud_storage(data: DataFrame, **kwargs) -> None:
    
    data['tpep_pickup_date']=data['tpep_pickup_datetime'].dt.date
    table=pa.Table.from_pandas(data)

    gcs=pa.fs.GcsFileSystem()

    pq.write_to_dataset(
        table,
        root_path=root_path,
        partition_cols=['tpep_pickup_date'],
        filesystem=gcs
    )
    
