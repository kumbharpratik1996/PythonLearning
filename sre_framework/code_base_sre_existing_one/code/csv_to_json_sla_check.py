###########################################################################################
# Code Name: csv_to_json_sla_check.py
# Purpose: This code converts CSV to JSON file for sla_check.
# Pre-requisite: Input CSV files for all pipelines should be available at location: \code_base\code\gen_csv\sla_check\*
# input: <pipeline>_sla_check.csv
# output: <pipeline>_sla_check.json
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
path = f"{parent_path}\gen_csv\sla_check"


# log file for this python script
log_file = f"{parent_path}\logs\python\csv_to_json_sla_check.log"


# removing old log files before execution
# os.remove(log_file)

if os.path.isfile(f"{log_file}"):
    os.remove(f"{log_file}")
    #print("Old logs clean-up completed!")
else:
    pass

# logging: log file
logging.basicConfig(filename=f"{log_file}", level=logging.DEBUG, filemode='a',
                    format = '%(levelname)s:%(asctime)s:%(filename)s:%(message)s')
logging.info("csv_to_json_sla_check.py logging Started!")

# changing path and checking for input directories
try:
    os.chdir(path)
except Exception as Argument:
    print(f"Input Path: {path} does not exist!\nPlease check the logs at: {log_file}")
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
                data = {"sre_sla_check": []}

                # Reading elements from Rows and storing it into 'data'
                for row in reader:
                    data["sre_sla_check"].append \
                        ({"project_name": row[0],
                          "dataset_name": row[1],
                          "table_name": row[2],
                          "name": row[3],
                          "threshould_diff_hour": row[4],
                          "schedule_dates": row[5],
                          "schedule_hour": row[6]
                          })
                # Directory for sla_check output.json
                path2 = f"{parent_path}\output_json_intermediate\sla_check"

                # Create Output Directory/Path if not exists
                if os.path.exists(path2):
                    with open(f"{parent_path}\output_json_intermediate\sla_check\{file_name}", "w") as f:
                        json.dump(data, f, indent=2)
                        logging.info(f"Dumping data into {file_name},")
                else:
                    os.makedirs(path2)
                    with open(f"{parent_path}\output_json_intermediate\sla_check\{file_name}", "w") as f:
                        json.dump(data, f, indent=2)
                        logging.info(f"Dumping data into {file_name},")
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