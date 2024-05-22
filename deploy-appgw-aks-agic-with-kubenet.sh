#!/usr/bin/env bash

resource_group="aks-ne-kubenet-investigation-01"
aks="aks-ne-kubenet-investigation-02"
application_gw_name="appgw-ne-kubenet-investigation-02"
application_gw_public_ip="pip-${application_gw_name}-kubenet"
vnet_name="vnet-ne-kubenet-investigation-02"
location="northeurope"

# Deploy resource group
az group create --name $resource_group --location $location

az aks create -n $aks -g $resource_group \
    --network-plugin kubenet \
    --enable-managed-identity \
    -a ingress-appgw \
    --appgw-name $application_gw_name \
    --appgw-subnet-cidr "10.226.0.0/16" \
    --generate-ssh-keys

# Get application gateway id from AKS addon profile
appGatewayId=$(az aks show -n $aks -g $resource_group -o tsv --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId")

# Get Application Gateway subnet id
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query "gatewayIPConfigurations[0].subnet.id")

# Get AGIC addon identity
agicAddonIdentity=$(az aks show -n $aks -g $resource_group -o tsv --query "addonProfiles.ingressApplicationGateway.identity.clientId")

# Assign network contributor role to AGIC addon identity to subnet that contains the Application Gateway
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"
