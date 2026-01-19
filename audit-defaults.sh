#!/usr/bin/env bash
set -euo pipefail

SCRIPT="${1:-./defaults.sh}"

echo "Comparing defaults keys in: $SCRIPT"
echo

# Extract: defaults write <domain> <key> ...
# (ignores commented lines)
grep -E '^[[:space:]]*defaults[[:space:]]+write[[:space:]]+' "$SCRIPT" \
| sed -E 's/^[[:space:]]*//g' \
| while read -r line; do
  domain="$(echo "$line" | awk '{print $3}')"
  key="$(echo "$line" | awk '{print $4}')"

  # If key is missing, skip
  [[ -z "${domain:-}" || -z "${key:-}" ]] && continue

  # Read current value (may fail if key absent)
  cur="$(defaults read "$domain" "$key" 2>/dev/null || echo "__MISSING__")"

  # Show what script is trying to set (raw line)
  echo "DOMAIN: $domain"
  echo "KEY:    $key"
  echo "CURRENT:$cur"
  echo "SCRIPT: $line"
  echo "----"
done

