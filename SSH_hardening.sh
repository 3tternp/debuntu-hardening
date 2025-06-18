#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"
BANNER_FILE="/etc/issue.net"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%T)"

# 🔁 Backup current SSH config
cp "$SSH_CONFIG" "$BACKUP" && echo "🔄 Backup saved at $BACKUP"

# 🧑‍💻 Detect valid local users with login shells
ALLOW_USERS="root $(awk -F: '($7 ~ /bash|sh|zsh|ksh/ && $3 >= 1000 && $1 != "nobody") {print $1}' /etc/passwd)"

# 🪧 Create banner file if missing
[ -f "$BANNER_FILE" ] || echo "Authorized access only. Unauthorized use is prohibited." > "$BANNER_FILE"

# ⚙️ Overwrite sshd_config with CIS-compliant configuration
cat <<EOF > "$SSH_CONFIG"
Protocol 2
LogLevel INFO
X11Forwarding no
MaxAuthTries 4
IgnoreRhosts yes
HostbasedAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
PermitUserEnvironment no
MACs hmac-sha2-512,hmac-sha2-256
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
Banner $BANNER_FILE
AllowUsers $ALLOW_USERS
EOF

# 🔐 Set secure permissions (CIS 5.2.1)
chown root:root "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"
echo "🔐 Permissions set to root:root 600 on $SSH_CONFIG"

# 🔁 Restart SSH service
systemctl restart sshd && echo "✅ SSH service restarted successfully."

# ✅ Final check
echo -e "\n🔍 Final sshd_config preview:"
grep -E '^(Protocol|LogLevel|X11Forwarding|MaxAuthTries|IgnoreRhosts|HostbasedAuthentication|PermitRootLogin|PermitEmptyPasswords|PermitUserEnvironment|MACs|ClientAliveInterval|ClientAliveCountMax|LoginGraceTime|Banner|AllowUsers)' "$SSH_CONFIG"
