#!/usr/bin/env bash

resource_group="aks-ne-kubenet-investigation-01"
aks="aks-ne-kubenet-investigation-02"
az aks get-credentials --resource-group $resource_group --name $aks