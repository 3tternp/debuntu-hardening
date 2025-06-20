#!/bin/bash

# Purpose: Remove group/world write permissions from users' dotfiles

echo "🔒 Securing user dotfiles in home directories..."

while IFS=: read -r username _ uid _ _ homedir shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell" != "/usr/sbin/nologin" && "$shell" != "/bin/false" ]]; then
        if [ -d "$homedir" ]; then
            echo "📂 Checking $username's dotfiles in $homedir"
            find "$homedir" -type f -name ".*" -perm /022 -exec chmod go-w {} \; 2>/dev/null
        fi
    fi
done < /etc/passwd

echo "✅ Dotfile permissions hardened."
