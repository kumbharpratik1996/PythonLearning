###########################################################################################
#Code Name: sre_generation_invoker.sh
#Purpose: This script is wrapper script which will execute end to end execuction of the SRE file generation.
#Pre-requisite: The yamls/git code should be available at the same location where script is available.
#Author:Prashant Ahire
#Revised Date: 06/13/2023
###########################################################################################

#!/bin/bash
echo -e "Cleaning existing directory and files\n"
rm -r ./output_sre_json > /dev/null 2>&1
rm -r ./gen_csv/ > /dev/null 2>&1
rm -r ./output_json_intermediate/ > /dev/null 2>&1
rm -r ./logs/shell/* > /dev/null 2>&1

echo -e "******Starting Reading sre_input file.csv file and creating metric csv file******\n"
sh ./code/sre_file_generation_input_optimize.sh sre_input_table.csv > ./logs/shell/sre_file_generation_input_optimize.log 

if [ $? -eq 0 ]; then
  echo -e "******sre_file_generation_input_optimize.sh executed successfully.******\n"
else
  echo "sre_file_generation_input_optimize.sh failed."
fi

echo -e "******Starting csv file conversion to json for csv_to_json_job_performance_check ******\n"
python ./code/csv_to_json_job_performance_check.py
if [ $? -eq 0 ]; then
  echo -e "******csv_to_json_job_performance_check.py executed successfully.******\n"
else
  echo "csv_to_json_job_performance_check.py failed."
fi

echo -e "******Starting csv file conversion to json csv_to_json_sla_check******\n"
python ./code/csv_to_json_sla_check.py 
if [ $? -eq 0 ]; then
  echo -e "******csv_to_json_sla_check.py  executed successfully.******\n"
else
  echo "csv_to_json_sla_check.py  failed."
fi

echo -e "******Starting csv file conversion to json csv_to_json_user_define_check******\n"
python ./code/csv_to_json_user_define_check.py
if [ $? -eq 0 ]; then
  echo -e "******csv_to_json_user_define_check.py executed successfully.******\n"
else
  echo "csv_to_json_user_define_check.py failed."
fi

echo -e "******Starting merging of all three metric in one file******\n"
sh ./code/merge.sh
if [ $? -eq 0 ]; then
  echo -e "******merge.sh executed successfully.******\n"
  echo -e "\nSRE file generation complete. Please check output_sre_json directory"
else
  echo "merge.sh failed."
fi


