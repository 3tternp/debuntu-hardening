#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

# Check if running in WSL
if grep -qiE '(microsoft|wsl)' /proc/version; then
  log "WSL environment detected. SELinux cannot be enabled. Exiting."
  exit 0
fi

log "Starting SELinux remediation steps..."

# 1. Remove SETroubleshoot if somehow installed (uncommon on Debian/Ubuntu)
log "Removing SETroubleshoot if installed..."
apt-get purge -y setroubleshoot || true

# 2. Install SELinux packages
log "Installing SELinux packages and default policy..."
apt-get update
apt-get install -y selinux-basics selinux-policy-default auditd

# 3. Enable SELinux in enforcing mode
log "Enabling and configuring SELinux in enforcing mode..."
selinux-activate
selinux-config-enforcing

# 4. Reboot is required
log "SELinux is now configured to enforce mode."
log "NOTE: A system reboot is required for SELinux to fully take effect."

exit 0
