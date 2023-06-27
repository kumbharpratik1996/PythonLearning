###########################################################################################
# Code Name: csv_to_json_job_performance_check.py
# Purpose: This code converts CSV to JSON file for job_performance_check.
# Pre-requisites: Input CSV files for all pipelines should be available at location: \code_base\code\gen_csv\job_performance_check\*
# input: <pipeline>_job_performance_check.csv
# output: <pipeline>_job_performance_check.json
# Authors: Prashant Ahire & Team
# Revised Date: 06/14/2023
###########################################################################################

import json
import csv
import os
import logging

# parent path of python file
parent_path = os.getcwd()

# path of input csv files
path = f"{parent_path}\gen_csv\job_performance_check"

# log file for this python script
log_file_path = f"{parent_path}\logs\python\csv_to_json_job_performance_check.log"


# removing old log files before execution
# os.remove(log_file_path)
if os.path.exists(f"{log_file_path}"):
    os.remove(f"{log_file_path}")
    #print("Old logs clean-up completed!")
else:
    pass

# logging: log file
logging.basicConfig(filename=f"{log_file_path}", level=logging.DEBUG, filemode='a',
                    format = '%(levelname)s:%(asctime)s:%(filename)s:%(message)s')
logging.info("csv_to_json_job_performance_check.py logging Started!")

# changing path and checking for input directories
try:
    os.chdir(path)
except Exception as Argument:
    print(f"Input Path: {path} does not exist!\nPlease check the logs at: {log_file_path}")
    # logging error details into the log file
    logging.exception("Input Directory does not exist!")
    exit(1)

# Check Count of Input CSV files
count = 0
for files in os.listdir(path):
    # check if current path is a file
    if os.path.isfile(os.path.join(path, files)):
        count += 1

# If count of input files >= 1, then for loop executes for each row to replicate it into the json format.
if count >= 1:
    logging.info(f"CSV to JSON conversion started for {count} files")
    # Iterative listing and processing of input csv file
    for file in os.listdir():
        # If condition to check file exists
        logging.info(f"{file}: conversion in process.")
        if os.path.isfile(file):
            # Variable to create output.json file name
            file_name = file.replace('.csv', '.json')

            # open csv file
            with open(f"{file}", "r") as f:
                # Reading input csv file --Note:- input csv file delimited by pipe, change accordingly if needed.
                reader = csv.reader(f, delimiter="|")
                next(reader)  # skip header(first) row for each csv file

                # Dictionary variable to store data in key-value
                data = {"sre_job_performance": []}

            # Reading elements from Rows and storing it into 'data'
                for row in reader:
                    data["sre_job_performance"].append\
                        ({"dag_name": row[0],
                          "Expected_execution_time_min": row[1],
                          "name": row[2],
                          "threshould_diff_hour": row[3],
                          "schedule_dates": row[4],
                          "schedule_hour": row[5]
                          })
                # Directory for job_performance_check output.json
                path2 = f"{parent_path}\output_json_intermediate\job_performance_check"

                # Create Output Directory/Path if not exists
                if os.path.exists(path2):
                    with open(f"{parent_path}\output_json_intermediate\job_performance_check\{file_name}", "w") as f:
                        json.dump(data, f, indent=2)
                        logging.info("JSON Data Dumping Done")
                else:
                    os.makedirs(path2)
                    with open(f"{parent_path}\output_json_intermediate\job_performance_check\{file_name}", "w") as f:
                        json.dump(data, f, indent=2)
                        logging.info("JSON Data Dumping Done")
            logging.info(f"{file_name}: conversion process completed!")
        # If input file not exist
        else:
            print(f"{file} does not exist!")
    print(f"Output JSON saved at {path2}")
    logging.info(f"Output JSON saved at {path2}")


# If count < 1
else:
    print(f"Input CSV files does not exist at {path} , please check shell script execution logs!")
    logging.exception(f"Files does not exist at {path} , please check shell script execution logs!")
