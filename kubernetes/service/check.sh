#!/bin/bash

PORT=30000
MASTER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $USER-control-plane)
echo "GET request on http://$MASTER_IP:$PORT"
curl http://$MASTER_IP:$PORT