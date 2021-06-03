#!/bin/bash

# Install and check kube-state-metrics for Prometheus operator
git clone https://github.com/devopscube/kube-state-metrics-configs.git
kubectl apply -f kube-state-metrics-configs/
kubectl get deployments kube-state-metrics -n kube-system