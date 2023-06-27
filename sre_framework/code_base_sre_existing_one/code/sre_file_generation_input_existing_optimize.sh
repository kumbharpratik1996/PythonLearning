###########################################################################################
#Code Name: sre_file_generation_input.sh
#Purpose: This code create csv file for sla_check, user_define_check and job_performance_check. This code identfies the dag_schedule from yamls and evaluatte schdule time for SRE.
#Pre-requisite: The yamls/git code should be available at the same location where script is available.
#input: sre_input_table.csv
#output: <pipeline>_sla_check.csv,<pipeline>_user_define_check and <pipeline>_job_performance_check.
#Assumptions: threshould_diff_hour="4", Expected_execution_time_min="60", schedule_dates="daily" 
#Author:Prashant Ahire
#Revised Date: 06/13/2023
###########################################################################################

#!/bin/bash

param_file=$1

dos2unix $param_file

echo "starting sre_file_generation_input_existing_optimize.sh"
date

# Deleting folder already exists
rm -r ./gen_csv/sla_check > /dev/null 2>&1
rm -r ./gen_csv/user_define_check > /dev/null 2>&1
rm -r ./gen_csv/job_performance_check > /dev/null 2>&1

# Creating folders
mkdir -p ./gen_csv/sla_check
mkdir -p ./gen_csv/job_performance_check
mkdir -p ./gen_csv/user_define_check

counter=0

# Reading input files
while IFS='|' read -r pipeline project_name dataset_name table_name column_name interval_days compare_value missing_metric; do
  if ((counter == 0)); then
    ((counter++))
    continue
  fi
  if [[ -z "$pipeline" || -z "$project_name" || -z "$dataset_name" || -z "$table_name" || -z "$column_name" || -z "$interval_days" || -z "$compare_value" || -z "$missing_metric" ]]; then
    echo "One or more parameters are empty in the line: $project_name|$dataset_name|$table_name|$column_name|$interval_days|$compare_value|$missing_metric"
  fi

  if [[ -z "$dataset_name" || -z "$table_name" ]]; then
    echo -e "Dataset name or table name is empty. Skipping YAML file scanning.\n"
    exit 1
  fi
  

  echo -e "\n*******Starting Creating metric for ${dataset_name}.${table_name}*******"
  
  if [[ "$project_name" == "enterprise" ]]; then
    project_id="cio-datahub-enterprise-pr-183a"
  elif [[ "$project_name" == "work" ]]; then
    project_id="cio-datahub-work-pr-0be526"
  else
    echo "Project name not provided correctly, it should be enterprise or work" 
	#continue
  fi
  
  gcloud config set project "$project_id"

  QUERY="SELECT CASE WHEN EXISTS ( SELECT 1 FROM  \`${dataset_name}.INFORMATION_SCHEMA.TABLES\` WHERE table_schema = '${dataset_name}'  AND table_name ='${table_name}' ) THEN 'PRESENT' ELSE 'NOTPRESENT' END AS result ;"
  
  table_availability=$("/c/Progra~1/Google/sdk/google-cloud-sdk/bin/bq.cmd" query --nouse_legacy_sql --headless --format=json "$QUERY" | awk -F '"' '{print $4}')
  
  if [[ "$table_availability" == "PRESENT" ]]; then
    echo "Table is available in BigQuery"
  if [[ -z "$column_name" ]]; then
    echo "Column for user_define_check query is not provided, deriving from the table.."
    #Setting project id
    gcloud config set project "$project_id"
	
    #SQL query to retrieve partition column
    QUERY="SELECT column_name FROM \`${dataset_name}.INFORMATION_SCHEMA.COLUMNS\` WHERE table_name = '${table_name}' AND is_partitioning_column='YES';"
    
    # Execute the query using the bq command
    column_name=$("/c/Progra~1/Google/sdk/google-cloud-sdk/bin/bq.cmd" query --nouse_legacy_sql --headless --format=json "$QUERY" | awk -F '"' '{print $4}')
    
    # Check partition column is found
        if [ -z "$column_name" ]; then
            echo "Table $table_name does not have a partition column, so adding last_updt_ts column for query."
			column_name="last_updt_ts"
        else
            if [ "$column_name" = "[]" ]; then
                echo "Table $table_name does not have a partition column, so adding last_updt_ts column for query ."
	            column_name="last_updt_ts"
            #else
                #if [[ "$column_name" == *"snapshot"* ]]; then
                #    column_name="last_updt_ts"
        		#	echo "As Partition column for table $table_name is snapshot changing the column for query to: $column_name"
                #fi
                #echo "Partition column for table $table_name: $column_name"
            fi
        fi
  fi
  found_matching_yaml=false
  
  #Constant values set
  threshould_diff_hour="3"
  Expected_execution_time_min="60"
  schedule_dates="daily"
  sre_schedule_add="3"

  # Create a temporary file to store the list of YAML files
  tmp_file=$(mktemp)
  find ./git/pipelines/$pipeline \( -type f -name "*.yaml" -o -name "*.yml" \) ! -name "*.py" > "$tmp_file"

  while IFS= read -r file_path; do
	if [[ "$project_name" == "enterprise" ]]; then
	  if awk '/int_table:|sourcelayer_table:/{print $2}' "$file_path" | grep -qw "${dataset_name}.${table_name}"; then
        dag_name=$(basename "$file_path" | sed 's/\.\///' | sed "s/.yaml//g" | sed "s/.yml//g")
		dag_schedule=$(awk -F "'" '/dag_schedule:/{print $2}' "$file_path")
		pipeline=$(awk '/pipeline:/{print $2}' "$file_path")
			if [[ -z "$dag_schedule" ]]; then
				find ./git/pipelines/"$pipeline" \( -type f -name "*.yaml" -o -name "*.yml" \) -exec grep -l "$dag_name" {} + | while read -r filename; do
				schedule=$(grep "dag_schedule:" "$filename" | grep -vq "@once" && grep "dag_schedule:" "$filename")
				dag_schedule=$(echo "$schedule" | sed "s/dag_schedule\://g" | sed "s/'//g" | awk '{print $2}')
				find_dag_name=$(grep -q "dag_name:" "$filename" && grep "dag_name:" "$filename")
				dag_name=$(echo "$find_dag_name" | awk '{print $2}')
				if [[ -z "$dag_schedule" ]]; then
					echo "Table found in historical YAML, skipping metric creation"
				else	
					if [[ -n "$dag_schedule" ]]; then
						hour=$(echo "$dag_schedule")
						if [[ "$hour" == *"/"* ]]; then
							echo "Actual DAG schedule for ${dataset_name}.${table_name} is hourly, which is $hour. Defaulting SRE schedule to 8."
							hour="5"
						fi
					
			# Convert hour to integer
			hour=$(echo "$dag_schedule")
			hour=$((10#$hour))
	
			# Calculate schedule_hour in 24-hour format
			schedule_hour=$((hour + $sre_schedule_add))
			if ((schedule_hour >= 24)); then
				schedule_hour=$((schedule_hour - 24))
			fi
          
		    # Split the missing_metric list into an array
            IFS=',' read -ra metrics <<< "$missing_metric"
            
            # Loop through each metric in the array
            for metric in "${metrics[@]}"; do
              case "$metric" in
                "sla_check")
                  # Code for sla_check metric
                  echo -e "sla_check metric is included in missing_metric\n"
				  # SLA CHECK file creation
                  if [[ ! -f "./gen_csv/sla_check/${pipeline}_sla_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
                  fi
                  echo -e "${project_name}|${dataset_name}|${table_name}|sla_check_${dataset_name}_${table_name}|${threshould_diff_hour}|$schedule_dates|${schedule_hour}" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
				  uniq ./gen_csv/sla_check/${pipeline}_sla_check.csv > ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv
			      mv ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv ./gen_csv/sla_check/${pipeline}_sla_check.csv
				  echo -e "\n*******Completed csv for metric sla_check -completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "user_define_check")
				  
                  # Code for user_define_check metric
                  echo -e "user_define_check metric is included in missing_metric\n"
				  
				  # User define check-completeness
                  if [[ ! -f "./gen_csv/user_define_check/${pipeline}_user_define_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|category|name|query|compare_type|compare_value|schedule_dates|schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
                  fi
                  echo -e "$project_name|$dataset_name|$table_name|completeness|average_row_count_${dataset_name}_${table_name}|SELECT floor(c*100/a) from(select count(*)/count(distinct date($column_name)) a,sum(case when date($column_name) >= date_sub(current_date,INTERVAL $interval_days day) then 1 else 0 end ) c FROM ent_cust_cust.bq_base_public_mobile WHERE date($column_name)>date_sub(current_date,INTERVAL $interval_days day))|>|$compare_value|$schedule_dates|$schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
				  uniq ./gen_csv/user_define_check/${pipeline}_user_define_check.csv > ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv
			      mv ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv ./gen_csv/user_define_check/${pipeline}_user_define_check.csv
				  echo -e "\n*******Completed csv for metric define_check-completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "job_performance_check")
                  # Code for job_performance metric
                  echo -e "job_performance metric is included in missing_metric\n"
				  
				  # job_performance_check-This will be for only single dag per table
                  if [[ ! -f "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv" ]]; then
                    echo -e "dag_name|Expected_execution_time_min|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
                  fi
                  echo -e "$dag_name|$Expected_execution_time_min|sre_job_performnce${dag_name}|$threshould_diff_hour|$schedule_dates|$schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
				  uniq ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv > ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv
			      mv ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv
				  echo -e "\n*******Completed csv for metric job_performance for ${dataset_name}.${table_name}*******\n"
				  
                  ;;
                *)
                  echo "Invalid metric: $metric"
                  ;;
              esac
            done
          found_matching_yaml=true
				fi
			fi
				done
			else 
				echo "echo else condtion $dag_schedule"
				dag_schedule=$(echo $dag_schedule |  sed "s/\@once//g" )
			
				if [[ -z "$dag_schedule" ]]; then
					echo "Table found in historical YAML, skipping metric creation"
				else
				hour=$(echo $dag_schedule | awk '{print $2}')
						
						if [[ "$hour" == *"/"* ]]; then
							echo "Actual DAG schedule for ${dataset_name}.${table_name} is hourly, which is $hour. Defaulting SRE schedule to 8."
							hour="5"
						fi

			# Convert hour to integer
			hour=$((10#$hour))
	
			# Calculate schedule_hour in 24-hour format
			schedule_hour=$((hour + $sre_schedule_add))
			if ((schedule_hour >= 24)); then
				schedule_hour=$((schedule_hour - 24))
			fi
			# Split the missing_metric list into an array
            IFS=',' read -ra metrics <<< "$missing_metric"
			for metric in "${metrics[@]}"; do
              case "$metric" in
                "sla_check")
                  # Code for sla_check metric
                  echo -e "sla_check metric is included in missing_metric\n"
				  # SLA CHECK file creation
                  if [[ ! -f "./gen_csv/sla_check/${pipeline}_sla_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
                  fi
                  echo -e "${project_name}|${dataset_name}|${table_name}|sla_check_${dataset_name}_${table_name}|${threshould_diff_hour}|$schedule_dates|${schedule_hour}" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
				  uniq ./gen_csv/sla_check/${pipeline}_sla_check.csv > ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv
			      mv ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv ./gen_csv/sla_check/${pipeline}_sla_check.csv
				  echo -e "\n*******Completed csv for metric sla_check -completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "user_define_check")
                  # Code for user_define_check metric
                  echo -e "user_define_check metric is included in missing_metric\n"
				  
				  # User define check-completeness
                  if [[ ! -f "./gen_csv/user_define_check/${pipeline}_user_define_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|category|name|query|compare_type|compare_value|schedule_dates|schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
                  fi
                  echo -e "$project_name|$dataset_name|$table_name|completeness|average_row_count_${dataset_name}_${table_name}|SELECT floor(c*100/a) from(select count(*)/count(distinct date($column_name)) a,sum(case when date($column_name) >= date_sub(current_date,INTERVAL $interval_days day) then 1 else 0 end ) c FROM ent_cust_cust.bq_base_public_mobile WHERE date($column_name)>date_sub(current_date,INTERVAL $interval_days day))|>|$compare_value|$schedule_dates|$schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
				  uniq ./gen_csv/user_define_check/${pipeline}_user_define_check.csv > ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv
			      mv ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv ./gen_csv/user_define_check/${pipeline}_user_define_check.csv
				  echo -e "\n*******Completed csv for metric define_check-completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "job_performance_check")
                  # Code for job_performance metric
                  echo -e "job_performance metric is included in missing_metric\n"
				  
				  # job_performance_check-This will be for only single dag per table
                  if [[ ! -f "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv" ]]; then
                    echo -e "dag_name|Expected_execution_time_min|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
                  fi
                  echo -e "$dag_name|$Expected_execution_time_min|sre_job_performnce${dag_name}|$threshould_diff_hour|$schedule_dates|$schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
				  uniq ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv > ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv
			      mv ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv
				  echo -e "\n*******Completed csv for metric job_performance for ${dataset_name}.${table_name}*******\n"
                  ;;
                *)
                  echo "Invalid metric: $metric"
                  ;;
              esac
            done
			fi
			fi
			found_matching_yaml=true
          #break
        fi
    elif [[ "$project_name" == "work" ]]; then
	  if awk '/staging_table:/{print $2}' "$file_path" | grep -qw "${dataset_name}.${table_name}"; then
        dag_name=$(basename "$file_path" | sed 's/\.\///' | sed "s/.yaml//g" | sed "s/.yml//g")
		dag_schedule=$(awk -F "'" '/dag_schedule:/{print $2}' "$file_path")
		pipeline=$(awk '/pipeline:/{print $2}' "$file_path")
			if [[ -z "$dag_schedule" ]]; then
				find ./git/pipelines/"$pipeline" \( -type f -name "*.yaml" -o -name "*.yml" \) -exec grep -l "$dag_name" {} + | while read -r filename; do
				#schedule=$(grep -q "dag_schedule:" "$filename" && grep "dag_schedule:" "$filename")
				schedule=$(grep "dag_schedule:" "$filename" | grep -vq "@once" && grep "dag_schedule:" "$filename")
				dag_schedule=$(echo "$schedule" | sed "s/dag_schedule\://g" | sed "s/'//g" | awk '{print $2}')
				find_dag_name=$(grep -q "dag_name:" "$filename" && grep "dag_name:" "$filename")
				dag_name=$(echo "$find_dag_name" | awk '{print $2}')
				if [[ -z "$dag_schedule" ]]; then
					echo "Table found in historical YAML, skipping metric creation"
				else	
					if [[ -n "$dag_schedule" ]]; then
						hour=$(echo "$dag_schedule")
						if [[ "$hour" == *"/"* ]]; then
							echo "Actual DAG schedule for ${dataset_name}.${table_name} is hourly, which is $hour. Defaulting SRE schedule to 8."
							hour="5"
						fi
            
					
			# Convert hour to integer
			hour=$(echo "$dag_schedule")
			hour=$((10#$hour))
	
			# Calculate schedule_hour in 24-hour format
			schedule_hour=$((hour + $sre_schedule_add))
			if ((schedule_hour >= 24)); then
				schedule_hour=$((schedule_hour - 24))
			fi

          # Split the missing_metric list into an array
            IFS=',' read -ra metrics <<< "$missing_metric"
            
            # Loop through each metric in the array
            for metric in "${metrics[@]}"; do
              case "$metric" in
                "sla_check")
                  # Code for sla_check metric
                  echo -e "sla_check metric is included in missing_metric\n"
				  
				  # SLA CHECK file creation
                  if [[ ! -f "./gen_csv/sla_check/${pipeline}_sla_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
                  fi
                  echo -e "${project_name}|${dataset_name}|${table_name}|sla_check_${dataset_name}_${table_name}|${threshould_diff_hour}|$schedule_dates|${schedule_hour}" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
				  uniq ./gen_csv/sla_check/${pipeline}_sla_check.csv > ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv
			      mv ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv ./gen_csv/sla_check/${pipeline}_sla_check.csv
				  echo -e "\n*******Completed csv for metric sla_check -completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "user_define_check")
                  # Code for user_define_check metric
                  echo -e "user_define_check metric is included in missing_metric\n"
				  
				  # User define check-completeness
                  if [[ ! -f "./gen_csv/user_define_check/${pipeline}_user_define_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|category|name|query|compare_type|compare_value|schedule_dates|schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
                  fi
                  echo -e "$project_name|$dataset_name|$table_name|completeness|average_row_count_${dataset_name}_${table_name}|SELECT floor(c*100/a) from(select count(*)/count(distinct date($column_name)) a,sum(case when date($column_name) >= date_sub(current_date,INTERVAL $interval_days day) then 1 else 0 end ) c FROM ent_cust_cust.bq_base_public_mobile WHERE date($column_name)>date_sub(current_date,INTERVAL $interval_days day))|>|$compare_value|$schedule_dates|$schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
				  uniq ./gen_csv/user_define_check/${pipeline}_user_define_check.csv > ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv
			      mv ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv ./gen_csv/user_define_check/${pipeline}_user_define_check.csv
				  echo -e "\n*******Completed csv for metric define_check-completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "job_performance_check")
                  # Code for job_performance metric
                  echo -e "job_performance metric is included in missing_metric\n"
				  
				  # job_performance_check-This will be for only single dag per table
                  if [[ ! -f "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv" ]]; then
                    echo -e "dag_name|Expected_execution_time_min|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
                  fi
                  echo -e "$dag_name|$Expected_execution_time_min|sre_job_performnce${dag_name}|$threshould_diff_hour|$schedule_dates|$schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
				  uniq ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv > ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv
			      mv ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv
				  echo -e "\n*******Completed csv for metric job_performance for ${dataset_name}.${table_name}*******\n"
                  ;;
                *)
                  echo "Invalid metric: $metric"
                  ;;
              esac
            done
          found_matching_yaml=true
		  fi
			fi
				done
			else 
				dag_schedule=$(echo $dag_schedule | sed "s/\@once//g")
				if [[ -z "$dag_schedule" ]]; then
					echo "Table found in historical YAML, skipping metric creation"
				else
					hour=$(echo $dag_schedule | awk '{print $2}')
					if [[ "$hour" == *"/"* ]]; then
						echo "Actual DAG schedule for ${dataset_name}.${table_name} is hourly, which is $hour. Defaulting SRE schedule to 8."
							hour="5"
					fi
				

			# Convert hour to integer
			hour=$((10#$hour))
	
			# Calculate schedule_hour in 24-hour format
			schedule_hour=$((hour + $sre_schedule_add))
			if ((schedule_hour >= 24)); then
				schedule_hour=$((schedule_hour - 24))
			fi
			
			# Split the missing_metric list into an array
            IFS=',' read -ra metrics <<< "$missing_metric"
			for metric in "${metrics[@]}"; do
              case "$metric" in
                "sla_check")
                  # Code for sla_check metric
                  echo -e "sla_check metric is included in missing_metric\n"
				  
				  # SLA CHECK file creation
                  if [[ ! -f "./gen_csv/sla_check/${pipeline}_sla_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
                  fi
                  echo -e "${project_name}|${dataset_name}|${table_name}|sla_check_${dataset_name}_${table_name}|${threshould_diff_hour}|$schedule_dates|${schedule_hour}" >> "./gen_csv/sla_check/${pipeline}_sla_check.csv"
				  uniq ./gen_csv/sla_check/${pipeline}_sla_check.csv > ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv
			      mv ./gen_csv/sla_check/${pipeline}_sla_check_temp.csv ./gen_csv/sla_check/${pipeline}_sla_check.csv
				  echo -e "\n*******Completed csv for metric sla_check -completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "user_define_check")
                  # Code for user_define_check metric
                  echo -e "user_define_check metric is included in missing_metric\n"
				  
				  # User define check-completeness
                  if [[ ! -f "./gen_csv/user_define_check/${pipeline}_user_define_check.csv" ]]; then
                    echo -e "project_name|dataset_name|table_name|category|name|query|compare_type|compare_value|schedule_dates|schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
                  fi
                  echo -e "$project_name|$dataset_name|$table_name|completeness|average_row_count_${dataset_name}_${table_name}|SELECT floor(c*100/a) from(select count(*)/count(distinct date($column_name)) a,sum(case when date($column_name) >= date_sub(current_date,INTERVAL $interval_days day) then 1 else 0 end ) c FROM ent_cust_cust.bq_base_public_mobile WHERE date($column_name)>date_sub(current_date,INTERVAL $interval_days day))|>|$compare_value|$schedule_dates|$schedule_hour" >> "./gen_csv/user_define_check/${pipeline}_user_define_check.csv"
				  uniq ./gen_csv/user_define_check/${pipeline}_user_define_check.csv > ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv
			      mv ./gen_csv/user_define_check/${pipeline}_user_define_check_temp.csv ./gen_csv/user_define_check/${pipeline}_user_define_check.csv
				  echo -e "\n*******Completed csv for metric define_check-completeness for ${dataset_name}.${table_name}*******\n"
                  ;;
                "job_performance_check")
                  # Code for job_performance metric
                  echo -e "job_performance metric is included in missing_metric\n"
				  
				  # job_performance_check-This will be for only single dag per table
                  if [[ ! -f "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv" ]]; then
                    echo -e "dag_name|Expected_execution_time_min|name|threshould_diff_hour|schedule_dates|schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
                  fi
                  echo -e "$dag_name|$Expected_execution_time_min|sre_job_performnce${dag_name}|$threshould_diff_hour|$schedule_dates|$schedule_hour" >> "./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv"
				  uniq ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv > ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv
			      mv ./gen_csv/job_performance_check/${pipeline}_job_performance_check_temp.csv ./gen_csv/job_performance_check/${pipeline}_job_performance_check.csv
				  echo -e "\n*******Completed csv for metric job_performance for ${dataset_name}.${table_name}*******\n"
                  ;;
                *)
                  echo "Invalid metric: $metric"
                  ;;
              esac
            done
			fi
			fi
			found_matching_yaml=true
          #break
        fi
      fi
	  #fi
  done < "$tmp_file"
    else
		echo "Table is not available in BigQuery"
  fi
  # Remove the temporary file
  

  if [[ "$found_matching_yaml" = false ]]; then
    echo "No matching YAML file found for dataset: $dataset_name and table: $table_name, skipping metric creation, please check yaml is available at correct location"
  fi
  rm "$tmp_file"
  
done < "$param_file"

echo "sre_file_generation_input_existing_optimize.sh process completed"
date

