#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SECRETS_DIR="$PROJECT_ROOT/secrets"

GENERATE_PASSWORDS="${GENERATE_PASSWORDS:-0}"
SECRET_LENGTH="${SECRET_LENGTH:-12}"
SPECIAL_CHARS="${SPECIAL_CHARS:-!@#%^*_+=-}"
ALPHANUM_CHARS='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

SECRETS_FILES=(
  "db_password.txt"
  "db_sup_password.txt"
  "db_root_password.txt"
  "wp_admin_password.txt"
  "wp_user_password.txt"
)

mkdir -p "$SECRETS_DIR"

if [[ ! "$GENERATE_PASSWORDS" =~ ^[01]$ ]]; then
  echo "Error: GENERATE_PASSWORDS must be 0 or 1"
  exit 1
fi

if [[ ! "$SECRET_LENGTH" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: SECRET_LENGTH must be a positive integer"
  exit 1
fi

generate_secret() {
  local length="$1"
  local charset="$2"
  local charset_len="${#charset}"
  local secret=""
  local random_number
  local index

  while (( ${#secret} < length )); do
    random_number="$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')"
    index=$(( random_number % charset_len ))
    secret+="${charset:index:1}"
  done

  printf '%s' "$secret"
}

create_secret_file() {
  local file_path="$1"
  local charset="${ALPHANUM_CHARS}${SPECIAL_CHARS}"

  if [[ -e "$file_path" ]]; then
    echo "Skip: $(basename "$file_path") already exists"
    return
  fi

  : >"$file_path"
  echo "Created empty: $(basename "$file_path")"
}

generate_secret_for_file() {
  local file_path="$1"
  local charset="${ALPHANUM_CHARS}${SPECIAL_CHARS}"
  local secret

  if [[ ! -f "$file_path" ]]; then
    echo "Error: $(basename "$file_path") is missing, run make secrets first"
    return 1
  fi

  if [[ -s "$file_path" ]]; then
    echo "Skip: $(basename "$file_path") already contains a password"
    return 0
  fi

  secret="$(generate_secret "$SECRET_LENGTH" "$charset")"
  printf '%s' "$secret" >"$file_path"
  echo "Generated password: $(basename "$file_path")"
}

if (( GENERATE_PASSWORDS == 1 )); then
  for file_name in "${SECRETS_FILES[@]}"; do
    generate_secret_for_file "$SECRETS_DIR/$file_name"
  done
else
  for file_name in "${SECRETS_FILES[@]}"; do
    create_secret_file "$SECRETS_DIR/$file_name"
  done
fi

echo "Secrets directory: $SECRETS_DIR"