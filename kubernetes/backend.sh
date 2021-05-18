#!/bin/bash

LABEL_SVC="backend"
SVC=$(kubectl get svc $LABEL_SVC 2>&1 > /dev/null)
ERR_SVC=Error.*AlreadyExists

LABEL_PVC="storedb"
PVC=$(kubectl get pvc $LABEL_PVC 2>&1 > /dev/null)
ERR_PVC=Error.*NotFound

if [[ "$SVC" =~ $ERR_SVC ]];
then 
    echo "SERVICE ALREADY EXISTS"
else
    if [[ "$PVC" =~ $ERR_PVC ]];
    then
        echo "VOLUME DOES NOT EXIST"
        kubectl create -f volume.yaml
        kubectl create -f service.yaml
    else
        echo "VOLUME ALREADY EXISTS"
        kubectl create -f service.yaml        
    fi
fi