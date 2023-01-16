#!/bin/bash
#bash script to delete tables from dynamodb
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
PROFILE="${3:?Please provide the profile}"

#exit on error
set -e

#list all tables
tableList=$(aws dynamodb list-tables --region $REGION --profile $PROFILE | jq .'TableNames[]' -r)
#if there are no tables exit script
if [ -z "$tableList" ]; then
    exit 0
fi
#delete tables
for table in $tableList; do
    aws dynamodb delete-table --table-name $table --region $REGION --profile $PROFILE
done
