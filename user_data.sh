#!/bin/bash

STAMP=$(date -u)
echo "Running at $STAMP" >> /root/ugh-wtf.log
echo "Running at $STAMP"

dnf install -y git awscli docker
export TFC_AGENT_TOKEN=$(aws secretsmanager get-secret-value --secret-id tfc-agent-token|jq -r .SecretString)
export TFC_AGENT_NAME=$(hostname)-1
# Current as of 2025-05-02
export VERSION=1.22.1
export TFC_AGENT_AUTO_UPDATE=disabled
docker run -d -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME docker.io/hashicorp/tfc-agent:$VERSION
export TFC_AGENT_NAME=$(hostname)-2
docker run -d -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME docker.io/hashicorp/tfc-agent:$VERSION

echo "Finished Running at $STAMP" >> /root/ugh-wtf.log
echo "Finished Running at $STAMP"
