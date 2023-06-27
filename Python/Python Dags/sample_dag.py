import os
from airflow import DAG
from datetime import datetime,timedelta
from airflow.operators.empty import EmptyOperator 
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

default_args = {
    'start_date' : '2023-5-6',
    'email_on failure' : False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}
def print_hello():
    print("Hello, I'm Pratik!")

with DAG(
    dag_id = 'my_first_dag',
    catchup=False,
    schedule=timedelta(days=1),
    default_args=default_args
) as dag:

    start = EmptyOperator(
        task_id = 'start',
        dag = dag
    )

    python_task = PythonOperator(
        task_id = 'python_task',
        python_callable=print_hello,
        dag=dag
    )
    end = EmptyOperator(
        task_id = 'end',
        dag=dag
    )


start >> python_task >> end