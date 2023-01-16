#!/bin/bash
#bash script to delete queues
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
PROFILE="${3:?Please provide the profile}"

#exit on error
set -e

#list all queueUrls
queueUrls=$(aws sqs list-queues --region $REGION --profile $PROFILE | jq -r '.QueueUrls[]')
#if there are no queues exit script
if [ -z "$queueUrls" ]; then
    exit 0
fi
for queueUrl in ${queueUrls}; do
    #delete queue
    aws sqs delete-queue --queue-url $queueUrl --region $REGION --profile $PROFILE
done
