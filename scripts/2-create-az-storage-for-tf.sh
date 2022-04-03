#!/bin/bash

source bash/log-functions.sh

APP_NAME="goalstrackers"
env="dev"
service_group="main"
RESOURCE_GROUP_NAME="tfstates"                # common for all apps
STORAGE_ACCOUNT_NAME="${APP_NAME}000tfstates" # specific for our app
CONTAINER_NAME="$env-tfstates"                # per environment, it will contain different service groups
location="westeurope"

logTitle "Parameters"
logParameter "APP_NAME" $APP_NAME
logParameter "env" $env
logParameter "service_group" $service_group
logParameter "RESOURCE_GROUP_NAME" $RESOURCE_GROUP_NAME
logParameter "STORAGE_ACCOUNT_NAME" $STORAGE_ACCOUNT_NAME
logParameter "CONTAINER_NAME" $CONTAINER_NAME
logParameter "location" $location

logTitle "Validating STORAGE_ACCOUNT_NAME"

num_chars=$(echo -n "$STORAGE_ACCOUNT_NAME" | wc -c)

if [[ $num_chars > 24 || ! $STORAGE_ACCOUNT_NAME =~ ^[0-9a-zA-Z]+$ ]]; then
    logError "STORAGE_ACCOUNT_NAME too long, it must be between 3 and 24, and only contain letters and numbers. Next are the conventions:"
    echo "https://docs.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-storage-account-name?tabs=bicep"
fi

logTitle "Creating Resource Group"
az group create --name $RESOURCE_GROUP_NAME --location $location

logTitle "Creating Storage Account"
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --kind "Storage" \
    --encryption-services blob \
    --tags "app=$APP_NAME"

logTitle "Creating Blob Container"
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME

logTitle "Getting Parameters for setting tf backend"

ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
logParameter "ACCOUNT_KEY" $ACCOUNT_KEY

logSuccess "Code to setup env vars"
echo "export TF_BACKEND_RESOURCE_GROUP_NAME=\"$RESOURCE_GROUP_NAME\""
echo "export TF_BACKEND_STORAGE_ACCOUNT_NAME=\"$STORAGE_ACCOUNT_NAME\""
echo "export TF_BACKEND_CONTAINER_NAME=\"$CONTAINER_NAME\""
echo "export TF_BACKEND_KEY=\"$env-$service_group.tfstate\""
