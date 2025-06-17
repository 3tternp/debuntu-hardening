#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_RULES_FILE="/etc/audit/rules.d/network-environment.rules"

log "Creating persistent audit rules for network environment changes..."

cat << 'EOF' > "$AUDIT_RULES_FILE"
# Audit hostname/domain name changes (64-bit)
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_env

# Audit hostname/domain name changes (32-bit)
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_env

# Watch key configuration files for changes
-w /etc/issue -p wa -k network_env
-w /etc/hosts -p wa -k network_env
-w /etc/network/ -p wa -k network_env
EOF

log "Reloading auditd rules..."
systemctl restart auditd

log "Audit rules for network environment modification events have been added and activated."
