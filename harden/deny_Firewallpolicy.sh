#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Applying default deny firewall policy..."

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback interface
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related incoming traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save rules persistently
apt-get install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4

log "Default deny firewall policy configured successfully."
