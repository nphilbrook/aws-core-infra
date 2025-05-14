#!/bin/bash

dnf install -y git awscli docker

cat <<'EOF' > /usr/local/bin/tfc-agent-wrapper
#!/bin/bash

export TFC_AGENT_TOKEN=$(aws secretsmanager get-secret-value --secret-id tfc-agent-token|jq -r .SecretString)
export TFC_AGENT_NAME=$(hostname)-$1
export TFC_AGENT_AUTO_UPDATE=disabled
# Current as of 2025-05-14
export VERSION=1.22.2
docker run -e TFC_AGENT_TOKEN -e TFC_AGENT_NAME -e TFC_AGENT_AUTO_UPDATE docker.io/hashicorp/tfc-agent:$VERSION
EOF

chmod 775 /usr/local/bin/tfc-agent-wrapper

cat <<EOF > /etc/systemd/system/tfc-agent@.service
[Unit]
Description=HCP Terraform Agent
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/tfc-agent-wrapper %I
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable tfc-agent@1.service
sudo systemctl enable tfc-agent@2.service

sudo systemctl start tfc-agent@1.service
sudo systemctl start tfc-agent@2.service
