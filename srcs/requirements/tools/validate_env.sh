#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/srcs/.env"
ENV_EXAMPLE_FILE="$PROJECT_ROOT/srcs/.env.example"

extract_env_names() {
  local file_path="$1"

  grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$file_path" | cut -d '=' -f 1
}

extract_env_value() {
  local env_name="$1"

  grep -E "^${env_name}=" "$ENV_FILE" | head -n 1 | cut -d '=' -f 2-
}

validate_wp_admin() {
  local wp_admin_value

  wp_admin_value="$(extract_env_value "WP_ADMIN")"

  if [[ "$wp_admin_value" =~ [Aa][Dd][Mm][Ii][Nn]([Ii][Ss][Tt][Rr][Aa][Tt][Oo][Rr])? ]]; then
    echo "Error: WP_ADMIN must not contain admin or administrator"
    return 1
  fi

  echo "OK: WP_ADMIN value"
}

if [[ ! -f "$ENV_EXAMPLE_FILE" ]]; then
  echo "Error: missing file $ENV_EXAMPLE_FILE"
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: missing file $ENV_FILE"
  exit 1
fi

status=0

while IFS= read -r env_name; do
  if grep -Eq "^${env_name}=" "$ENV_FILE"; then
    echo "OK: $env_name"
  else
    echo "Error: missing variable $env_name in $ENV_FILE"
    status=1
  fi
done < <(extract_env_names "$ENV_EXAMPLE_FILE")

if grep -Eq '^WP_ADMIN=' "$ENV_FILE"; then
  if ! validate_wp_admin; then
    status=1
  fi
fi

if (( status != 0 )); then
  echo ".env validation failed"
  exit 1
fi

echo ".env is valid"