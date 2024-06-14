#!/bin/bash

## Set Variables ##
export TF_VAR_project_name="3tierdemo"
export TF_VAR_env="test"
export TF_VAR_region="eastus"
export TF_VAR_subscription_id="03f869b7-7505-4b61-9287-f320c883399f"
export TF_VAR_allowed_location_policy_id="/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
export TF_VAR_resource_groups='["networking", "webserver", "application", "database", "storage", "vault"]'
export TF_VAR_vnet_cidr="10.10.0.0/16"
export TF_VAR_public_subnet_cidrs='["10.10.0.0/24", "10.10.1.0/24"]'
export TF_VAR_private_subnet_cidrs='["10.10.10.0/24", "10.10.11.0/24"]'
export TF_VAR_public_app_gateway_cidr="10.10.9.0/26"
export TF_VAR_public_bastion_cidr="10.10.9.64/26"
export TF_VAR_public_ips='["natgateway", "bastion", "appgateway"]'
export TF_VAR_create_storage_account=true
export TF_VAR_create_keyvault=true

#terraform init
terraform apply