#!/usr/bin/env bash
# Description: Script to create a service principal used by terraform
# Parameters:
#   app_name
#   env
#   subscription_id

# repo_url: https://github.com/cangulo-templates/az-scripts-templates
# repo_version: 0.0.1

source bash/log-functions.sh

# SOURCE THIS FILE TO LOAD THE ENV VARIABLES
# Reference
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

# PROVIDE PARAMETERS MANUALLY
# echo "please provide app_name:"
# read app_name
# echo "please provide env:"
# read env
# echo "please provide subscription_id:"
# read subscription_id
# echo "please provide the role:"
# read role

# PROVIDE PARAMETERS AS SCRIPT
# app_name=""
# env=""
# subscription_id=""
# role=""
# role="Contributor"

sp_name="tf_${app_name}_${env}"

logTitle "Parameters"
logParameter "app_name" $app_name
logParameter "env" $env
logParameter "subscription_id" $subscription_id
logParameter "sp_name" $sp_name

logTitle "az login"
az login --only-show-errors

logTitle "setting subscription $subscription_id"
az account set --subscription $subscription_id --only-show-errors

logTitle "creating service principal $sp_name"

sp_details=$(az ad sp create-for-rbac \
    --name $sp_name \
    --role "$role" \
    --scopes "/subscriptions/$subscription_id")

if [[ -z "${sp_details}" ]]; then
    logError "error creating sp"
    exit -1
else
    logSuccess "sp created successful"
    # echo -e $sp_details | jq
fi

app_id=$(jq '.appId' -r <<<${sp_details})
displayName=$(jq '.displayName' -r <<<${sp_details})
password=$(jq '.password' -r <<<${sp_details})
tenant_id=$(jq '.tenant' -r <<<${sp_details})

logSuccess "sp created. Details:"
logParameter "app_id" $app_id
logParameter "displayName" $displayName
logParameter "password" $password
logParameter "tenant_id" $tenant_id

logTitle "adding permission. Parameters:"
microsoft_graph_id="00000003-0000-0000-c000-000000000000"
application_read_write_all="1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9"

logParameter "app_id" $app_id
logParameter "microsoft_graph_id" $microsoft_graph_id
logParameter "application_read_write_all" $application_read_write_all

az ad app permission add \
    --id $app_id \
    --api $microsoft_graph_id \
    --api-permissions "$application_read_write_all=Role"

sleep 20s

logTitle "granting admin-consent"
az ad app permission admin-consent \
    --id $app_id

logTitle "setting ARM env vars for TF"

export ARM_CLIENT_ID=$app_id
export ARM_CLIENT_SECRET=$password
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_TENANT_ID=$tenant_id

logSuccess "# START: Parameters"

logParameter "ARM_CLIENT_ID" $ARM_CLIENT_ID
logParameter "ARM_CLIENT_SECRET" $ARM_CLIENT_SECRET
logParameter "ARM_SUBSCRIPTION_ID" $ARM_SUBSCRIPTION_ID
logParameter "ARM_TENANT_ID" $ARM_TENANT_ID"\n"

logSuccess "# code for exporting secrets for TF\n"

echo "export ARM_CLIENT_ID=\"$ARM_CLIENT_ID\""
echo "export ARM_CLIENT_SECRET=\"$ARM_CLIENT_SECRET\""
echo "export ARM_SUBSCRIPTION_ID=\"$ARM_SUBSCRIPTION_ID\""
echo -e "export ARM_TENANT_ID=\"$ARM_TENANT_ID\"\n"

logSuccess "# code login out azure"
echo -e "az logout\n"

logSuccess "# code for login to azure using sp $sp_name"
echo "az login --service-principal -u \"$app_id\" -p \"$password\" --tenant \"$tenant_id\""
echo "az account set --subscription \"$subscription_id\""
