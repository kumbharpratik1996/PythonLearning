##########################################################################################################
# Code Name: Merge.py
# Purpose: This code Merges Delta JSON Data or Missing Matrix Checks Data into Existing SRE <pipeline>.json file.
# Pre-requisites:
#        1. Input Delta JSON files at location: \code\output_intermediate_json\*
#        2. Git Repository for existing <pipeline>.json files
# input: <pipeline>_job_performance_check.json ,  <pipeline>_sla_check.json, <pipeline>_user_define_check.json
# output: <pipeline>.json
# Authors: Prashant Ahire & Team
# Revised Date: 06/15/2023
############################################################################################################


import json
import os
import logging
import shutil

# parent path of python file
parent_path = os.getcwd()

# path of input json files
output_json_intermediate = f"{parent_path}\output_json_intermediate"

# Git Repository
git_path = f"{parent_path}\git"

#Final Merge Output Path
# merged_output_path = f"{parent_path}\merged_output_path"

# log file for this python script
log_file = f"{parent_path}\logs\python\merge.log"

# removing old log files before execution
# os.remove(log_file)
if os.path.isfile(f"{log_file}"):
    os.remove(f"{log_file}")
    #print("Old logs clean-up completed!")
else:
    pass

def find_file(pipeline_name, git_path):
    for root, dirs, files in os.walk(git_path):
        if pipeline_name in files:
            return os.path.join(root, pipeline_name)
    return None

def merge_data(git_data, new_data, key):
    if git_data is None:
        git_data = {}

    if key in new_data:
        if key not in git_data:
            git_data[key] = new_data[key]
        else:
            existing_records = git_data[key]
            new_records = []

            if key in ['sre_sla_check', 'user_define_check']:
                new_records = [
                    item
                    for item in new_data[key]
                    if (item['dataset_name'], item['table_name']) not in [
                        (record['dataset_name'], record['table_name'])
                        for record in existing_records
                    ]
                ]
            elif key == 'sre_job_performance':
                new_records = [
                    item
                    for item in new_data[key]
                    if item['dag_name'] not in [record['dag_name']
                        for record in existing_records]
                ]

            git_data[key].extend(new_records)

    return git_data

# logging: log file
logging.basicConfig(filename=f"{log_file}", level=logging.INFO, filemode='a',
                    format = '%(levelname)s:%(asctime)s:%(filename)s:%(message)s')
logging.info("Merge.py logging Started!")

# Check Input Directory, If Not Exists - throws Exception & Exit!
try:
    os.chdir(output_json_intermediate)
except Exception as Argument1:
    print(f"{output_json_intermediate}: Directory does not exist\nLogs Saved at: {log_file}")
    logging.exception(f"{output_json_intermediate}: Directory does not exist")
    exit(1)

# Delete Old Output Directory/Files
# if os.path.exists(merged_output_path):
#     shutil.rmtree(merged_output_path)
#     logging.info("Old Output files Cleanup-Completed!")
# else:
#     pass

# # Create Output Directory
# os.mkdir(merged_output_path)
# logging.info(f"{merged_output_path}: Directory Created!")

# Count of Input Directories of SRE Check
count = 0
for directories in os.listdir(output_json_intermediate):
    # check if current path is a file
    if os.path.exists(directories):
        count += 1

# If count of input directory >= 1
if count >= 1:
    print("******Merge Process Started******")
    logging.info("******Merge Process Started******")
    sr_num = 1
    sre_keys = {"job_performance_check":"sre_job_performance","sla_check":"sre_sla_check","user_define_check":"user_define_check"}
    for dir in os.listdir(output_json_intermediate):
        print(f"{sr_num}.{dir} Directory Found & Proceeding to merge:")
        logging.info(f"{sr_num}.{dir} Directory Found & Proceeding to merge:")
        sr_num += 1
        ################### job_performance_check #########################
        if dir in sre_keys:
            chk_dir = f"{output_json_intermediate}\{dir}"
            f_count = 0
            for directories in os.listdir(chk_dir):
                # check if current path is a file
                if os.path.exists(chk_dir):
                    f_count += 1
            if f_count >= 1:
                for file in os.listdir(chk_dir):
                    new_file_name =  f"{chk_dir}\{file}"
                    with open(new_file_name,"r") as f:
                        new_data = json.load(f)
                        pipeline_name = file.replace(f"_{dir}", "")
                        git_file_name = find_file(pipeline_name, git_path)
                        if git_file_name:
                            with open(git_file_name,"r+",encoding="utf-8-sig") as g:
                                git_data = json.load(g)
                                result = merge_data(git_data,new_data,sre_keys[dir])
                                g.seek(0)
                                g.truncate()
                                json.dump(result,g,indent=2)
                                print(f"{pipeline_name}: Completed!")
                                logging.info(f"{pipeline_name}: Completed!")
                        else:
                            print(f"Error: {pipeline_name} does not exist in git clone!!")
                            logging.info(f"Error: {pipeline_name} does not exist in git clone!!")
            else:
                print("No files found for merge!")
                logging.info("No files found for merge!")
        else:
            pass
else:
    print(f"SRE Check Directories Not found inside {output_json_intermediate}\nLogs Saved at: {log_file}")
    logging.exception(f"SRE Check Directories Not found inside: {output_json_intermediate}")
    exit(1)