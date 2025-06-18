#!/bin/bash

FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
BACKUP_DATE=$(date +%F-%T)

for file in "${FILES[@]}"; do
  # Backup file
  cp "$file" "$file.bak.$BACKUP_DATE" && echo "🔁 Backup created: $file.bak.$BACKUP_DATE"

  # Add pam_faillock.so preauth line after pam_env
  grep -q "pam_faillock.so preauth" "$file" || \
    sed -i '/^auth.*required.*pam_env.so/a auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' "$file"

  # Add pam_faillock.so authfail line after pam_unix.so
  grep -q "pam_faillock.so authfail" "$file" || \
    sed -i '/^auth.*sufficient.*pam_unix.so/a auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' "$file"

  # Add account line
  grep -q "pam_faillock.so" "$file" || \
    sed -i '/^account.*required.*pam_unix.so/a account     required      pam_faillock.so' "$file"
done

echo "✅ Lockout policy for failed login attempts has been configured (deny=5, unlock_time=900s)."
