import json
import csv
import os

path = "D:\Shell script\SLA_check"
os.chdir(path)
for file in os.listdir():

    file_name=file.replace('.csv','.json')
    with open(file, "r") as f:
        reader = csv.reader(f)
        next(reader)
        data = {"sre_sla_check": []}
        for row in reader:
            data["sre_sla_check"].append \
                ({"project_name": row[0],
                  "dataset_name": row[1],
                  "table_name": row[2],
                  "name": row[3],
                  "threshould_diff_hour": row[4],
                  "schedule_dates": row[5],
                  "schedule_hour": row[6],
                  })
        path2="D:\Shell script\SLA_check_json"
        if os.path.exists(path2):
            with open(f"D:\Shell script\SLA_check_json\{file_name}", "w") as f:
                json.dump(data, f, indent=2)
        else:
            os.mkdir(path2)
            with open(f"D:\Shell script\SLA_check_json\{file_name}", "w") as f:
                json.dump(data, f, indent=2)

