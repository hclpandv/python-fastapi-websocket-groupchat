#!/usr/bin/env bash

resource_group="aks-we-kubenet-investigation-01"
aks="aks-ne-kubenet-investigation-02"

# enable approuting add-on
az aks approuting enable --resource-group $resource_group --name $aks
