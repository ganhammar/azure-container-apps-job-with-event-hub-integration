#!/bin/bash

set -e

project_name="processor"
resource_group="rg-$project_name"
location="swedencentral"
container_registry_namespace_prefix="azure-container-apps-job-with-event-hub-integration"
container_registry_token=$DOCKER_PASSWORD

az group create --name "$resource_group" --location "$location"

az deployment group create \
    --resource-group "$resource_group" \
    --template-file "infra/main.bicep" \
    --parameters location="$location" \
    --parameters projectName="$project_name" \
    --parameters containerRegistryNamespacePrefix="$container_registry_namespace_prefix" \
    --parameters containerRegistryToken="$container_registry_token"
