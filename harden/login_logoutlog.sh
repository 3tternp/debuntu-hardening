#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_RULES_FILE="/etc/audit/rules.d/login-events.rules"

log "Creating persistent audit rules for login/logout tracking..."

cat << 'EOF' > "$AUDIT_RULES_FILE"
# Track successful and failed login attempts
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins
EOF

log "Restarting auditd to apply changes..."
systemctl restart auditd

log "Login and logout audit rules have been configured and activated."
