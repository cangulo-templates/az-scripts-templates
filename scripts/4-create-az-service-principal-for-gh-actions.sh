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
app_name=""
env=""
subscription_id=""
role="Contributor"

sp_name="gh_action_${app_name}_${env}"

logTitle "Parameters"
logParameter "app_name" $app_name
logParameter "env" $env
logParameter "subscription_id" $subscription_id
logParameter "role" $role
logParameter "sp_name" $sp_name

logTitle "az login"
az login --only-show-errors

logTitle "setting subscription $subscription_id"
az account set --subscription $subscription_id --only-show-errors

logTitle "creating service principal $sp_name"
logParameter "sp_name" $sp_name

az ad sp create-for-rbac \
    --name $sp_name \
    --role contributor \
    --scopes /subscriptions/$subscription_id \
    --sdk-auth
