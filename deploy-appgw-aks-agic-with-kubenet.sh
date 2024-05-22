#!/usr/bin/env bash

resource_group="aks-ne-kubenet-investigation-01"
aks="aks-ne-kubenet-investigation-02"
application_gw_name="appgw-ne-kubenet-investigation-02"
application_gw_public_ip="pip-${application_gw_name}-kubenet"
vnet_name="vnet-ne-kubenet-investigation-02"
location="northeurope"

# Deploy resource group
az group create --name $resource_group --location $location

# # Create virtual network and subnets for Kubenet cluster
# az network vnet create -g $resource_group -n $vnet_name --address-prefix 10.1.0.0/8

# # Create subnet for AKS nodes with Kubenet
# az network vnet subnet create -g $resource_group --vnet-name $vnet_name -n aks-subnet-kubenet --address-prefix 10.241.0.0/16

# # Create subnet for Application Gateway for Kubenet cluster
# az network vnet subnet create -g $resource_group --vnet-name $vnet_name -n appgw-subnet-kubenet --address-prefix 10.226.0.0/24

# # Deploy Application Gateway for Kubenet cluster and get its ID and subnet ID
# az network public-ip create -g $resource_group -n $application_gw_public_ip --allocation-method Static --sku Standard

# az network application-gateway create -n $application_gw_name -l $location -g $resource_group --sku WAF_v2 --public-ip-address $application_gw_public_ip --vnet-name $vnet_name_kubenet --subnet appgw-subnet-kubenet

# appGatewayId_kubenet=$(az network application-gateway show -n $application_gw_name -g $resource_group -o tsv --query "id")
# appGatewaySubnetId_kubenet=$(az network vnet subnet show -g $resource_group --vnet-name $vnet_name_kubenet -n appgw-subnet-kubenet -o tsv --query "id")

az aks create -n $aks -g $resource_group \
    --network-plugin kubenet \
    --enable-managed-identity \
    -a ingress-appgw \
    --appgw-name $application_gw_name \
    --appgw-subnet-cidr "10.226.0.0/16" \
    --generate-ssh-keys

# # Deploy AKS with AGIC ingress addon using Kubenet
# az aks create -n $aks -g $resource_group \
#     --network-plugin kubenet \
#     --vnet-subnet-id $(az network vnet subnet show -g $resource_group --vnet-name $vnet_name_kubenet -n aks-subnet-kubenet -o tsv --query "id") \
#     --enable-managed-identity \
#     -a ingress-appgw \
#     --appgw-name $application_gw_name \
#     --generate-ssh-keys

# Get application gateway id from AKS addon profile
appGatewayId=$(az aks show -n $aks -g $resource_group -o tsv --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId")

# Get Application Gateway subnet id
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query "gatewayIPConfigurations[0].subnet.id")

# Get AGIC addon identity
agicAddonIdentity=$(az aks show -n $aks -g $resource_group -o tsv --query "addonProfiles.ingressApplicationGateway.identity.clientId")

# Assign network contributor role to AGIC addon identity to subnet that contains the Application Gateway
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"
