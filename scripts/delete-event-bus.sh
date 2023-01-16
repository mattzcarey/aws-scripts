#!/bin/bash
#bash script to delete an event bus
STAGE="${1:?Please provide the stage}"
REGION="${2:?Please provide the region}"
EVENT_BUS_NAME="${3:?Please provide the event bus name}"
PROFILE="${4:?Please provide the profile}"

#exit on error
set -e

#list event buses, if there are none exit script
eventBuses=$(aws events list-event-buses --region $REGION --profile $PROFILE)
# if the only EventBus is the default EventBus exit script
if [ $(echo "${eventBuses}" | jq -r '.EventBuses[] | select(.Name == "default") | .Name') = "default" ]; then
    exit 0
fi

#delete event bus rules
deleteRules() {
    rulesList=$(aws events list-rules --event-bus-name $EVENT_BUS_NAME --region $REGION --profile $PROFILE | jq '.Rules[]' -r)
    for rule in rulesList; do
        ruleName=$(rule | jq '.Name' -r)
        #if ruleName is empty exit function
        if [ -z "$ruleName" ]; then
            continue
        fi
        #remove targets first
        targets=$(aws events list-targets-by-rule --rule $ruleName --event-bus-name $STAGE-global-event-bus --region $REGION --profile $PROFILE)
        for target in $(echo "${targets}" | jq -r '.Targets[] | @base64'); do
            _jq() {
                echo ${target} | base64 --decode | jq -r ${1}
            }
            targetId=$(_jq '.Id')
            aws events remove-targets --rule $ruleName --event-bus-name $EVENT_BUS_NAME --ids $targetId --region $REGION --profile core
        done
        #delete rule
        aws events delete-rule --name $ruleName --event-bus-name $EVENT_BUS_NAME --region $REGION --profile $PROFILE
    done
}

#delete event bus
deleteBus() {
    aws events delete-event-bus --name $EVENT_BUS_NAME --region $REGION --profile $PROFILE
}

#call functions if either errors, exit script with error
deleteRules || exit 1
deleteBus || exit 1
