#!/bin/bash

ERR=*"NotFound"*

LABEL_SVC="backend"
SVC=$(kubectl get svc $LABEL_SVC 2>&1 > /dev/null)

LABEL_PVC="storedb"
PVC=$(kubectl get pvc $LABEL_PVC 2>&1 > /dev/null)

LABEL_SEC="secretdb"
SEC=$(kubectl get secret $LABEL_SEC 2>&1 > /dev/null)

if [[ "$SVC" == $ERR ]];
then 
    if [[ "$PVC" == $ERR ]] && [[ "$SEC" == $ERR ]];
    then
        echo "VOLUME DOES NOT EXIST"
        echo "SECRET DOES NOT EXIST"
        kubectl create -f volume.yaml
        kubectl create -f secret.yaml
        kubectl create -f service.yaml
    elif [[ "$PVC" == $ERR ]] && [[ "$SEC" != $ERR ]];
    then
        echo "VOLUME DOES NOT EXIST"
        echo "SECRET ALREADY EXISTS"
        kubectl create -f volume.yaml
        kubectl create -f service.yaml
    elif [[ "$PVC" != $ERR ]] && [[ "$SEC" == $ERR ]];
    then
        echo "VOLUME ALREADY EXISTS"
        echo "SECRET DOES NOT EXIST"
        kubectl create -f secret.yaml
        kubectl create -f service.yaml
    else
        echo "VOLUME ALREADY EXISTS"
        echo "SECRET ALREADY EXISTS"
        kubectl create -f service.yaml        
    fi
else
    echo "SERVICE ALREADY EXISTS"
fi