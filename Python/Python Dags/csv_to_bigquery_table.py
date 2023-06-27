from datetime import datetime
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import CsvToBigQueryOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 5, 4),
    'retries': 0
}

dag = DAG(
    'csv_to_bigquery',
    default_args=default_args,
    schedule_interval=None,
    catchup=False
)

load_csv_to_bq = CsvToBigQueryOperator(
    task_id='load_csv_to_bq',
    bucket='your_bucket_name',
    source_objects=['path/to/your/file.csv'],
    destination_project_dataset_table='your_project.your_dataset.your_table',
    schema_fields=[
        {'name': 'column1', 'type': 'STRING'},
        {'name': 'column2', 'type': 'INTEGER'},
        {'name': 'column3', 'type': 'FLOAT'},
    ],
    skip_leading_rows=1,  # Skip the header row
    dag=dag
)

load_csv_to_bq
