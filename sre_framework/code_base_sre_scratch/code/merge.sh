###########################################################################################
#Code Name: merge.sh
#Purpose: This code merges 3 json files metrics to 1 json file 
#input: <pipeline>_sla_check.json, <pipeline>_user_define_check.json and <pipeline>_job_performance_check.json
#output: <pipeline>.json
#Author:Pratik Kumbhar
#Revised Date: 06/13/2023
###########################################################################################

#!/bin/bash
ls ./output_json_intermediate/job_performance_check/*_job_performance*
if [ $? -eq 0 ]; then
  break
else
  exit 1
fi

variable=$(ls ./output_json_intermediate/job_performance_check/*_job_performance* | sed 's/_job_performance_check.json$//' | cut -d '/' -f4 | tr '\n' ',' | sed 's/.$//')

mkdir -p ./output_sre_json
echo $variable

IFS=","
for i in $variable
do
    echo "{" >> ./output_sre_json/$i.json 
    echo "\"pipeline\":\"${i}\"," >> ./output_sre_json/$i.json
    sed -e '1d' -e '$d' ./output_json_intermediate/sla_check/$i"_sla_check.json" >> ./output_sre_json/$i.json
    echo "," >> ./output_sre_json/$i.json
    sed -e '1d' -e '$d' ./output_json_intermediate/user_define_check/$i"_user_define_check.json" >> ./output_sre_json/$i.json
    echo "," >> ./output_sre_json/$i.json
    sed -e '1d' -e '$d' ./output_json_intermediate/job_performance_check/$i"_job_performance_check.json" >> ./output_sre_json/$i.json
    echo "}" >> ./output_sre_json/$i.json
done
echo "SRE for $variable created."