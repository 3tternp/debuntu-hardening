#!/bin/bash
# Enhanced Debian/Ubuntu Hardening Script with Consent and Menu
# Applies selected scripts from 'harden' folder
# Version: 1.0.1

set -euo pipefail
IFS=$'\n\t'

# Function to center text in the terminal
center_text() {
    local text="$1"
    local term_width=$(tput cols)
    # Maximum banner width (based on longest line or reasonable limit)
    local max_line_width=44
    # Calculate padding to center the text
    local padding=$(( (term_width - max_line_width) / 2 ))
    if [ $padding -lt 0 ]; then
        padding=0
    fi
    # Print each line with padding
    while IFS= read -r line; do
        printf "%${padding}s%s\n" "" "$line"
    done <<< "$text"
}

# Define banner text
banner_text=$(cat << 'EOF'
========================================
   CIS Debian/Ubuntu Hardening Script
========================================
Version: 1.0.1       Developed by: Astra
========================================
EOF
)

# Display centered banner
center_text "$banner_text"

# Warning and Consent
echo ""
echo "WARNING: This script applies system-level hardening based on the CIS Benchmark."
echo "It may disable or remove packages and modify critical settings."
echo "Use only on test systems or with full understanding of the impact."

read -p "Do you accept and wish to proceed? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Operation aborted by user."
  exit 1
fi

# Menu to select hardening script from 'harden' folder
echo ""
echo "Available hardening scripts from the 'harden' folder:"
SCRIPT_DIR="harden"

if [ ! -d "$SCRIPT_DIR" ]; then
  echo "Error: '$SCRIPT_DIR' directory not found."
  exit 1
fi

scripts=($(ls $SCRIPT_DIR))
PS3="Choose the script number to execute (or Ctrl+C to cancel): "

select script in "${scripts[@]}"; do
  if [[ -n "$script" && -f "$SCRIPT_DIR/$script" ]]; then
    echo "Running script: $script"
    chmod +x "$SCRIPT_DIR/$script"
    sudo bash "$SCRIPT_DIR/$script"
    break
  else
    echo "Invalid selection. Try again."
  fi
done
