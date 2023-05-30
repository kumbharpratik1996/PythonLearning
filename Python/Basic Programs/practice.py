# num = 2
# sum_of_digits=0
# digit = 95 % 10
# print(digit)
# sum_of_digits += digit

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def task_1():
    print("Executing Task 1")

def task_2():
    print("Executing Task 2")

# Define the DAG
dag = DAG(
    'my_first_dag',
    description='A simple DAG',
    start_date=datetime(2023, 5, 29),
    #schedule_interval=None
)

# Define the tasks
task1 = PythonOperator(
    task_id='task_1',
    python_callable=task_1,
    dag=dag
)

task2 = PythonOperator(
    task_id='task_2',
    python_callable=task_2,
    dag=dag
)

# Set the task dependencies
task1 >> task2
