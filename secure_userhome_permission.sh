#!/bin/bash

# Purpose: Ensure users' home directories have restrictive permissions (750 or more restrictive)

echo "🔐 Securing user home directory permissions..."

while IFS=: read -r username _ uid _ _ homedir shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell" != "/usr/sbin/nologin" && "$shell" != "/bin/false" ]]; then
        if [ -d "$homedir" ]; then
            perms=$(stat -c "%a" "$homedir")
            if [ "$perms" -gt 750 ]; then
                echo "⚠️  $username home directory ($homedir) has permissions $perms. Fixing to 750..."
                chmod 750 "$homedir"
            fi
        fi
    fi
done < /etc/passwd

echo "✅ Home directory permissions hardened."
