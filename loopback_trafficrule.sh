#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Configuring loopback traffic rules in iptables..."

# Accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Drop spoofed traffic to 127.0.0.0/8 that doesn't use loopback interface
iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

# Save rules persistently
apt-get install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4

log "Loopback traffic properly configured."
