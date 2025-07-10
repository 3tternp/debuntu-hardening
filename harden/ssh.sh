#!/bin/bash
# CIS Debian/Ubuntu SSH Hardening Script
# Applies CIS Benchmark recommendations for SSH configuration with user-specified username and port
# Version: 1.0.8
# Developed by: Astra

# Ensure script runs with bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be run with bash, not sh or another shell."
    echo "Run as: sudo bash harden/ssh.sh"
    exit 1
fi

set -eu
IFS=$'\n\t'

# Ensure dos2unix is installed and convert script to Unix line endings
if ! command -v dos2unix >/dev/null 2>&1; then
    echo "Installing dos2unix to ensure Unix line endings..."
    apt-get update && apt-get install -y dos2unix || { echo "Error: Failed to install dos2unix."; exit 1; }
fi
SCRIPT_PATH=$(readlink -f "$0")
dos2unix "$SCRIPT_PATH" >/dev/null 2>&1 || { echo "Error: Failed to convert $SCRIPT_PATH to Unix line endings."; exit 1; }
# Verify line endings
if cat -v "$SCRIPT_PATH" | grep -q $'\r'; then
    echo "Error: Windows line endings detected in $SCRIPT_PATH after dos2unix."
    exit 1
fi
echo "✅ Ensured Unix line endings for $SCRIPT_PATH"

# Define file paths
SSH_CONFIG="/etc/ssh/sshd_config"
BANNER_FILE="/etc/issue.net"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%T)"
TEMP_CONFIG="/tmp/sshd_config_temp"

# Debugging: Verify variables
echo "DEBUG: SSH_CONFIG=$SSH_CONFIG"
echo "DEBUG: BANNER_FILE=$BANNER_FILE"
echo "DEBUG: BACKUP=$BACKUP"
echo "DEBUG: TEMP_CONFIG=$TEMP_CONFIG"

# Warning and Consent
echo "WARNING: This script modifies $SSH_CONFIG based on CIS Benchmark."
echo "It will change the SSH port, restrict users, and restart the SSH service."
echo "Ensure you have an alternative access method (e.g., console) to avoid lockout."
echo "Use only on test systems or with full understanding of the impact."
read -p "Do you accept and wish to proceed? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Operation aborted by user."
    exit 1
fi

# Check if sshd is installed
if ! command -v sshd >/dev/null 2>&1; then
    echo "Error: OpenSSH server (sshd) is not installed. Install it with 'sudo apt-get install openssh-server'."
    exit 1
fi

# Function to validate port
validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ && $port -ge 1 && $port -le 65535 ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate username
validate_username() {
    local username=$1
    if [[ $username =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*$ && -n $(id "$username" 2>/dev/null) ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt for user input
echo ""
echo "Enter username(s) for SSH access (space-separated, existing users only):"
read -r input_users
if [ -z "$input_users" ]; then
    echo "Error: At least one username must be provided."
    exit 1
fi

# Validate each username
ALLOW_USERS=""
for user in $input_users; do
    if validate_username "$user"; then
        ALLOW_USERS="$ALLOW_USERS $user"
    else
        echo "Error: Invalid or non-existing username '$user'. Check if the user exists."
        exit 1
    fi
done
ALLOW_USERS=$(echo "$ALLOW_USERS" | xargs) # Trim whitespace
if [ -z "$ALLOW_USERS" ]; then
    echo "Error: No valid usernames provided."
    exit 1
fi

echo "Enter SSH port to configure (1-65535, avoid 22 if possible):"
read -r SSH_PORT
if ! validate_port "$SSH_PORT"; then
    echo "Error: Invalid port number. Must be between 1 and 65535."
    exit 1
fi

# Check if port is in use (excluding current SSHD process)
if command -v netstat >/dev/null 2>&1 && netstat -tuln | grep -q ":$SSH_PORT "; then
    echo "Error: Port $SSH_PORT is already in use by another service."
    exit 1
fi

# 🔁 Backup current SSH config
if [ -z "$SSH_CONFIG" ]; then
    echo "Error: SSH_CONFIG variable is empty."
    exit 1
fi
if [ ! -f "$SSH_CONFIG" ]; then
    echo "Error: $SSH_CONFIG not found. Ensure OpenSSH server is installed."
    exit 1
fi
cp "$SSH_CONFIG" "$BACKUP" || { echo "Error: Failed to create backup at $BACKUP."; exit 1; }
echo "🔄 Backup saved at $BACKUP"
if [ ! -f "$BACKUP" ]; then
    echo "Error: Backup file $BACKUP does not exist."
    exit 1
fi

# 🪧 Create banner file if missing (CIS 5.2.7)
if [ -z "$BANNER_FILE" ]; then
    echo "Error: BANNER_FILE variable is empty."
    exit 1
fi
[ -f "$BANNER_FILE" ] || echo "Authorized access only. Unauthorized use is prohibited." > "$BANNER_FILE"
chown root:root "$BANNER_FILE" || { echo "Error: Failed to set permissions on $BANNER_FILE."; exit 1; }
chmod 644 "$BANNER_FILE" || { echo "Error: Failed to set permissions on $BANNER_FILE."; exit 1; }
echo "🪧 Banner file configured at $BANNER_FILE"

# ⚙️ Write to temporary sshd_config
if [ -z "$SSH_PORT" ] || [ -z "$ALLOW_USERS" ]; then
    echo "Error: SSH_PORT or ALLOW_USERS variable is empty."
    exit 1
fi
cat <<EOF > "$TEMP_CONFIG"
# CIS Benchmark SSH Configuration
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

# 🔍 Test temporary sshd_config
if ! sshd -t -f "$TEMP_CONFIG" >/dev/null 2>"$TEMP_CONFIG.err"; then
    echo "Error: Invalid SSH configuration in $TEMP_CONFIG. Details:"
    cat "$TEMP_CONFIG.err"
    rm -f "$TEMP_CONFIG" "$TEMP_CONFIG.err"
    echo "Aborting without modifying $SSH_CONFIG."
    exit 1
fi
rm -f "$TEMP_CONFIG.err"

# 🔁 Move temporary config to final location
mv "$TEMP_CONFIG" "$SSH_CONFIG" || { echo "Error: Failed to move $TEMP_CONFIG to $SSH_CONFIG."; exit 1; }

# 🔐 Set secure permissions (CIS 5.2.1)
if [ -z "$SSH_CONFIG" ]; then
    echo "Error: SSH_CONFIG variable is empty during permission setting."
    exit 1
fi
chown root:root "$SSH_CONFIG" || { echo "Error: Failed to set permissions on $SSH_CONFIG."; exit 1; }
chmod 600 "$SSH_CONFIG" || { echo "Error: Failed to set permissions on $SSH_CONFIG."; exit 1; }
echo "🔐 Permissions set to root:root 600 on $SSH_CONFIG"

# 🔁 Restart SSH service
if systemctl restart sshd 2>/dev/null; then
    echo "✅ SSH service restarted successfully on port $SSH_PORT."
else
    echo "Error: Failed to restart SSH service. Reverting to backup..."
    cp "$BACKUP" "$SSH_CONFIG" || { echo "Error: Failed to restore backup from $BACKUP."; exit 1; }
    systemctl restart sshd 2>/dev/null || echo "Error: Unable to restart SSH service after reverting."
    echo "🔄 Restored $SSH_CONFIG from backup."
    exit 1
fi

# ✅ Final check
echo -e "\n🔍 Final sshd_config preview:"
grep -E '^(Port|Protocol|LogLevel|X11Forwarding|MaxAuthTries|IgnoreRHosts|HostbasedAuthentication|PermitRootLogin|PermitEmptyPasswords|PermitUserEnvironment|Ciphers|MACs|KexAlgorithms|ClientAliveInterval|ClientAliveCountMax|LoginGraceTime|Banner|AllowUsers)' "$SSH_CONFIG"

echo -e "\n⚠️ IMPORTANT: SSH is now running on port $SSH_PORT."
echo "Update your SSH client configuration (e.g., ssh -p $SSH_PORT $USER@$HOST)."
echo "Test connectivity before closing this session to avoid lockout."
