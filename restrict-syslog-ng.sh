#!/bin/bash

set -euo pipefail

# Get the remote log host IP or network to allow
read -rp "Enter the allowed remote log server IP or network: " ALLOWED_HOST

# Backup the original syslog-ng configuration file
CONFIG_FILE="/etc/syslog-ng/syslog-ng.conf"
BACKUP_FILE="/etc/syslog-ng/syslog-ng.conf.bak"
echo "[+] Backing up $CONFIG_FILE to $BACKUP_FILE"
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Adding configuration to restrict incoming remote syslog-ng messages to allowed host(s)
echo "[+] Configuring syslog-ng to accept messages only from $ALLOWED_HOST..."

sudo tee -a "$CONFIG_FILE" >/dev/null <<EOF

# Restrict incoming remote messages to specific IP
source s_net {
    tcp(ip("${ALLOWED_HOST}"));
};

destination d_remote {
    tcp("127.0.0.1" port(514)); # Example local destination
};

log {
    source(s_net);
    destination(d_remote);
};
EOF

# Restart syslog-ng service to apply changes
echo "[+] Restarting syslog-ng service..."
sudo systemctl restart syslog-ng

echo "[✅] syslog-ng is now configured to only accept messages from $ALLOWED_HOST"
