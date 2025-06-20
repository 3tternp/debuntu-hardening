#!/bin/bash

# Fix: Enforce correct permissions on audit configuration files

set -e

echo "🔍 Securing audit rules..."

# Set permissions on /etc/audit/audit.rules
if [ -f /etc/audit/audit.rules ]; then
  chmod 640 /etc/audit/audit.rules
  chown root:root /etc/audit/audit.rules
  echo "✅ /etc/audit/audit.rules secured"
fi

# Set permissions on /etc/audit/rules.d/*.rules
if ls /etc/audit/rules.d/*.rules 1> /dev/null 2>&1; then
  chmod 640 /etc/audit/rules.d/*.rules
  chown root:root /etc/audit/rules.d/*.rules
  echo "✅ /etc/audit/rules.d/*.rules files secured"
fi

echo "✅ Audit system file permissions are correctly configured."
