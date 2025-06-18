#!/bin/bash

PAM_FILE="/etc/pam.d/system-auth"
BACKUP_FILE="$PAM_FILE.bak.$(date +%F-%T)"

# 🔁 Backup the current PAM configuration
cp "$PAM_FILE" "$BACKUP_FILE" && echo "🔁 Backup saved at $BACKUP_FILE"

# 🧹 Remove existing pam_pwhistory line (if any)
sed -i '/^password.*pam_pwhistory.so/ d' "$PAM_FILE"

# ➕ Append secure password history enforcement
echo 'password    requisite     pam_pwhistory.so remember=5 use_authtok' >> "$PAM_FILE"

echo "✅ Password reuse policy enforced: last 5 passwords remembered"
