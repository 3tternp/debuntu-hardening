#!/bin/bash

# CIS Password Policy Hardening Script
# Applies to Debian/Ubuntu systems

set -euo pipefail
DATE=$(date +%F-%H%M%S)

echo "🔐 Applying CIS password policy fixes..."

# Backup
backup_file() {
  [[ -f "$1" ]] && cp -p "$1" "$1.bak.$DATE" && echo "📁 Backup created: $1.bak.$DATE"
}
backup_file /etc/pam.d/common-password
backup_file /etc/pam.d/common-auth
backup_file /etc/login.defs
backup_file /etc/default/useradd

# 5.3.1 - Password creation policy
if ! grep -q 'pam_pwquality.so' /etc/pam.d/common-password; then
  echo "✅ Setting password creation policy"
  echo 'password requisite pam_pwquality.so retry=3 minlen=14 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1' >> /etc/pam.d/common-password
fi

# 5.3.2 - Lockout policy
if ! grep -q 'pam_tally2.so' /etc/pam.d/common-auth; then
  echo "✅ Enabling login lockout"
  echo 'auth required pam_tally2.so onerr=fail deny=5 unlock_time=900' >> /etc/pam.d/common-auth
fi

# 5.3.3 - Password reuse
if ! grep -q 'pam_pwhistory.so' /etc/pam.d/common-password; then
  echo "✅ Enforcing password reuse policy"
  echo 'password required pam_pwhistory.so remember=5 use_authtok' >> /etc/pam.d/common-password
fi

# 5.3.4 - SHA-512 hashing
echo "✅ Enforcing SHA-512 password hashing"
sed -i '/pam_unix.so/ s/\bmd5\b//g; s/\bsha256\b//g; s/\bsha512\b//g; s/$/ sha512/' /etc/pam.d/common-password
sed -i '/^ENCRYPT_METHOD/ c\ENCRYPT_METHOD SHA512' /etc/login.defs || echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs

# 5.4.1.1 - Password expiration
echo "✅ Setting password expiration to 90 days"
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs

# 5.4.1.2 - Minimum days between changes
echo "✅ Setting minimum days between password change to 7"
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs

# 5.4.1.4 - Inactive lock after 30 days
echo "✅ Setting inactive lock to 30 days"
if grep -q '^INACTIVE=' /etc/default/useradd; then
  sed -i 's/^INACTIVE=.*/INACTIVE=30/' /etc/default/useradd
else
  echo "INACTIVE=30" >> /etc/default/useradd
fi

echo "🎉 All selected CIS password-related controls remediated."
