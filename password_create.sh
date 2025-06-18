#!/bin/bash

CONF_FILE="/etc/security/pwquality.conf"
BACKUP="/etc/security/pwquality.conf.bak.$(date +%F-%T)"

# 🔁 Backup current config
cp "$CONF_FILE" "$BACKUP" && echo "🔄 Backup saved at $BACKUP"

# 🛡️ Enforce strong password policies as per CIS benchmark
declare -A pw_policies=(
  ["minlen"]="14"
  ["dcredit"]="-1"
  ["ucredit"]="-1"
  ["ocredit"]="-1"
  ["lcredit"]="-1"
)

# Apply each setting
for key in "${!pw_policies[@]}"; do
  val="${pw_policies[$key]}"
  if grep -qE "^#?\s*${key}" "$CONF_FILE"; then
    sed -i "s/^#*\s*${key}.*/${key} = ${val}/" "$CONF_FILE"
  else
    echo "${key} = ${val}" >> "$CONF_FILE"
  fi
done

echo "✅ Password creation policies updated in $CONF_FILE"
