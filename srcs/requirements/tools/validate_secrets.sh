#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SECRETS_DIR="$PROJECT_ROOT/secrets"

SECRETS_FILES=(
  "db_password.txt"
  "db_sup_password.txt"
  "db_root_password.txt"
  "wp_admin_password.txt"
)

is_valid_secret() {
  local file_path="$1"
  local secret

  if [[ ! -f "$file_path" ]]; then
    echo "Error: missing file $(basename "$file_path")"
    return 1
  fi

  # Remove newline characters to measure the effective secret length.
  secret="$(tr -d '\r\n' <"$file_path")"

  if [[ -z "$secret" ]]; then
    echo "Error: $(basename "$file_path") is empty"
    return 1
  fi

  if (( ${#secret} < 8 )); then
    echo "Error: $(basename "$file_path") must contain at least 8 characters"
    return 1
  fi

  echo "OK: $(basename "$file_path")"
  return 0
}

if [[ ! -d "$SECRETS_DIR" ]]; then
  echo "Error: secrets directory not found at $SECRETS_DIR"
  exit 1
fi

status=0

for file_name in "${SECRETS_FILES[@]}"; do
  if ! is_valid_secret "$SECRETS_DIR/$file_name"; then
    status=1
  fi
done

if (( status != 0 )); then
  echo "Secrets validation failed"
  exit 1
fi

echo "All secrets are valid"