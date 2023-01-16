#!/bin/bash
#bash script to delete s3 buckets
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
PROFILE="${3:?Please provide the profile}"

#exit on error
set -e

#list all buckets not containing name 'cdk'
bucketList=$(aws s3api list-buckets --region $REGION --profile $PROFILE | jq .'Buckets[] | select(.Name | contains("cdk") | not) | .Name' -r)
echo $bucketList
#check bucket list is not empty
if [ -z "$bucketList" ]; then
    exit 0
fi
#delete buckets
for bucket in $bucketList; do
    #check for versioning enabled
    if [ "$(aws s3api get-bucket-versioning --bucket $bucket --region $REGION --profile $PROFILE | jq -r '.Status')" == "Enabled" ]; then
        #delete all versions
        aws s3api list-object-versions --bucket $bucket --region $REGION --profile $PROFILE | jq -r '.Versions[] | .Key' | while read key; do
            aws s3api delete-object --bucket $bucket --key $key --region $REGION --profile $PROFILE
        done
    else
        # empty bucket
        aws s3 rm s3://$bucket --recursive --region $REGION --profile $PROFILE
    fi
    #delete bucket
    aws s3api delete-bucket --bucket $bucket --region $REGION --profile $PROFILE
done
