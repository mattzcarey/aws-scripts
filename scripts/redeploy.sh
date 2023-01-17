#!/bin/bash
#bash script to redeploy infrastructure
STAGE="staging"
REGION="eu-central-1"

#before running this script make sure you have the following installed:
aws --version
#AWS accounts array: uncomment below or add your own
#accounts=("default")
accounts=("core" "users" "accounts" "messaging")
cognito_account="core"

# exit when any command fails
set -e

#if stage = production then exit
if [ $STAGE = "production" ]; then
    echo "You cannot redeploy production"
    exit 1
fi

#pull the latest code from git branch main
echo "Pulling latest code from git branch main"
git checkout main && git pull

#install dependencies and package backend
#check yarn scripts in your package.json and modify the following if necessary
echo "Installing dependencies and packaging backend packages"
yarn install && yarn package-backend

function destroy {
    set -e
    echo "Removing resources with RemovalPolicy.Remain ....."

    #delete UserPools
    #set DELETEALL ($3) to "true" to delete all userpools on this account,
    #otherwise set to "false" to just delete the pool associated with this stage
    ./scripts/delete-user-pools.sh $STAGE $REGION "true" $cognito_account

    #delete all dynamodb tables
    for i in ${accounts[@]}; do
        ./scripts/delete-tables.sh $STAGE $REGION $i
    done

    #delete global event bus
    ./scripts/delete-event-bus.sh $STAGE $REGION $STAGE-global-event-bus core

    #delete all local event buses
    for i in ${accounts[@]}; do
        ./scripts/delete-event-bus.sh $STAGE $REGION $STAGE-$i-local-event-bus $i
    done

    #delete queues
    for i in ${accounts[@]}; do
        ./scripts/delete-queues.sh $STAGE $REGION $i
    done

    #delete s3 buckets
    for i in ${accounts[@]}; do
        ./scripts/delete-s3-buckets.sh $STAGE $REGION $i
    done

    #delete log groups
    for i in ${accounts[@]}; do
        ./scripts/delete-log-groups.sh $STAGE $REGION $i
    done

    #destroy stacks
    echo "Destroying stacks ....."
    for i in ${accounts[@]}; do
        yarn --cwd ./backend/$i/ destroy -c stage=$STAGE -c region=$REGION
    done
}

function deploy {
    set -e
    echo "Deploying stacks ....."
    for i in ${accounts[@]}; do
        yarn --cwd ./backend/$i/ deploy -c stage=$STAGE -c region=$REGION
    done
}

#call functions
main() {
    destroy
    deploy
}

if main; then
    echo "Success: redeployed $STAGE"
fi
