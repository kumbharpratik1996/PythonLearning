# CreateBucket = GoogleCloudStorageCreateBucketOperator(
#     task_id=CreateNewBucket,
#     bucket_name=test-bucket,
#     storage_class=MULTI_REGIONAL,
#     location=EU,
#     labels={env dev, team airflow},
#     gcp_conn_id=airflow-conn-id,
# )