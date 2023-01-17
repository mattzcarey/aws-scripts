#!/bin/bash

#bash script to delete log groups
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
PROFILE="${3:?Please provide the profile}"

#exit on error
set -e

#list all log groups
logGroups=$(aws logs describe-log-groups --region $REGION --profile $PROFILE | jq -r '.logGroups[] | select(.logGroupName | contains("'$STAGE'")) | .logGroupName')
if [ -z "$logGroups" ]; then
    exit 0
fi
for logGroup in ${logGroups}; do
    aws logs delete-log-group --log-group-name $logGroup --region $REGION --profile $PROFILE
done
