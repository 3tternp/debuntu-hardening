#!/bin/bash

set -e

echo "🔍 Checking and configuring SHA-512 password hashing..."

# 🔁 Backup files
cp /etc/login.defs /etc/login.defs.bak.$(date +%F-%T)
cp /etc/pam.d/common-password /etc/pam.d/common-password.bak.$(date +%F-%T)

# ✅ Update /etc/login.defs
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
    sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
else
    echo 'ENCRYPT_METHOD SHA512' >> /etc/login.defs
fi
echo "✅ ENCRYPT_METHOD set to SHA512 in /etc/login.defs"

# ✅ Ensure correct PAM setting in /etc/pam.d/common-password
COMMON_PASSWORD="/etc/pam.d/common-password"
if grep -q "^password.*pam_unix.so" "$COMMON_PASSWORD"; then
    sed -i '/^password.*pam_unix.so/ s/\bmd5\b//g; s/\bsha256\b//g; s/\bsha512\b//g; s/$/ sha512/' "$COMMON_PASSWORD"
    echo "✅ pam_unix.so updated to use SHA512 in $COMMON_PASSWORD"
else
    echo 'password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512' >> "$COMMON_PASSWORD"
    echo "✅ Added pam_unix.so line with SHA512 to $COMMON_PASSWORD"
fi

# ✅ Done
echo "🎉 SHA-512 password hashing algorithm is now enforced."
