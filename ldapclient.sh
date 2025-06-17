#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking for installed LDAP client packages..."

ldap_packages=(ldap-utils libnss-ldap libpam-ldap)
removed=false

for pkg in "${ldap_packages[@]}"; do
  if dpkg -l | grep -qw "$pkg"; then
    log "Removing $pkg..."
    apt-get purge -y "$pkg"
    removed=true
  fi
done

if [ "$removed" = false ]; then
  log "No LDAP client packages are installed. No action needed."
else
  log "LDAP client packages removed successfully."
fi

exit 0
