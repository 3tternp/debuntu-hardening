#!/bin/bash
# CIS Debian/Ubuntu SSH Hardening Script
# Applies CIS Benchmark recommendations for SSH configuration with user-specified username and port

if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be run with bash."
    exit 1
fi

set -eu
IFS=$'\n\t'

# Ensure dos2unix is installed
if ! command -v dos2unix >/dev/null 2>&1; then
    echo "Installing dos2unix..."
    apt-get update && apt-get install -y dos2unix
fi

SCRIPT_PATH=$(readlink -f "$0")
dos2unix "$SCRIPT_PATH" >/dev/null 2>&1

# Configuration paths
SSH_CONFIG="/etc/ssh/sshd_config"
BANNER_FILE="/etc/issue.net"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%T)"
TEMP_CONFIG="/tmp/sshd_config_temp"

echo "WARNING: This script modifies $SSH_CONFIG and restarts SSH service."
read -p "Do you accept and wish to proceed? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Operation aborted."
    exit 1
fi

# Check sshd installed
command -v sshd >/dev/null || { echo "OpenSSH server not installed."; exit 1; }

validate_port() {
    [[ $1 =~ ^[0-9]+$ && $1 -ge 1 && $1 -le 65535 ]]
}

validate_username() {
    id "$1" &>/dev/null
}

# Read users
read -rp "Enter allowed SSH usernames (space-separated): " input_users
[ -z "$input_users" ] && { echo "User input required."; exit 1; }

ALLOW_USERS=""
for user in $input_users; do
    validate_username "$user" && ALLOW_USERS="$ALLOW_USERS $user" || { echo "Invalid user: $user"; exit 1; }
done
ALLOW_USERS=$(echo "$ALLOW_USERS" | xargs)

# Read port
read -rp "Enter SSH port (1-65535): " SSH_PORT
validate_port "$SSH_PORT" || { echo "Invalid port."; exit 1; }

# Check port conflict
netstat -tuln 2>/dev/null | grep -q ":$SSH_PORT " && { echo "Port $SSH_PORT in use."; exit 1; }

cp "$SSH_CONFIG" "$BACKUP" || exit 1
[ -f "$BANNER_FILE" ] || echo "Authorized access only." > "$BANNER_FILE"
chown root:root "$BANNER_FILE"; chmod 644 "$BANNER_FILE"

cat <<EOF > "$TEMP_CONFIG"
Port $SSH_PORT
Protocol 2
LogLevel INFO
X11Forwarding no
MaxAuthTries 4
IgnoreRHosts yes
HostbasedAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
PermitUserEnvironment no
Ciphers aes256-ctr,aes128-ctr
MACs hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,diffie-hellman-group-exchange-sha256
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
Banner $BANNER_FILE
AllowUsers $ALLOW_USERS
EOF

sshd -t -f "$TEMP_CONFIG" || { echo "Invalid SSH config."; cat "$TEMP_CONFIG"; exit 1; }

mv "$TEMP_CONFIG" "$SSH_CONFIG"
chown root:root "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"
systemctl restart sshd || { cp "$BACKUP" "$SSH_CONFIG"; systemctl restart sshd; echo "Reverted due to error."; exit 1; }

echo "SSH restarted on port $SSH_PORT. Config:"
grep -E '^(Port|Protocol|LogLevel|X11Forwarding|MaxAuthTries|IgnoreRHosts|HostbasedAuthentication|PermitRootLogin|PermitEmptyPasswords|PermitUserEnvironment|Ciphers|MACs|KexAlgorithms|ClientAliveInterval|ClientAliveCountMax|LoginGraceTime|Banner|AllowUsers)' "$SSH_CONFIG"
