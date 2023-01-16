#!/bin/bash
#bash script to delete a userpool
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
DELETEALL="${3:?Write "true" to delete all userpools on this account}"
PROFILE="${4:?Please provide the profile}"

set -e

#delete either #STAGE-user-pool or all userpools
if [ $DELETEALL = "true" ]; then
    #delete all userpools
    USERPOOLID=$(aws cognito-idp list-user-pools --max-results 60 --region $REGION --profile $PROFILE | jq -r '.UserPools[] | .Id')
    for id in $USERPOOLID; do
        aws cognito-idp delete-user-pool --user-pool-id $id --region $REGION --profile $PROFILE
    done
else
    #delete singular userpool
    aws cognito-idp delete-user-pool --user-pool-id $(aws cognito-idp list-user-pools --max-results 60 --region $REGION --profile $PROFILE | jq -r '.UserPools[] | select(.Name == "'$STAGE'-user-pool") | .Id') --region $REGION --profile $PROFILE
fi
