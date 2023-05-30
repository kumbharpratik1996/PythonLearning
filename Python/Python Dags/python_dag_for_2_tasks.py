from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def task_1():
    print("This is the first task")

def task_2():
    print("This is the second task")

#Define the DAG
dag = DAG(
    dag_id='print_string',
    description='',
    start_date=datetime(2023, 5,29),
    schedule_interval='0 1 * * *',
)

#Define the tasks

task1 = PythonOperator(
    task_id='task1',
    python_callable=task_1,
    dag=dag
)
task2 = PythonOperator(
    task_id='task2',
    python_callable=task_2,
    dag=dag
)

#Set the task dependencies

task1 >> task2
