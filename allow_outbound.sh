#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Configuring firewall to allow outbound and established/related connections..."

# Allow all outbound traffic
iptables -A OUTPUT -j ACCEPT

# Allow inbound responses to established or related outbound connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Save rules persistently
apt-get install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4

log "Outbound and established connection rules configured successfully."
