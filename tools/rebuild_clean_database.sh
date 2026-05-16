#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-bwps_clean_test}"
CONFIRM_RESET="${CONFIRM_RESET:-}"

if [[ "${DB_NAME}" != *_test && "${DB_NAME}" != *_dev && "${DB_NAME}" != bwps_clean_* ]]; then
  echo "Refusing to rebuild database '${DB_NAME}'." >&2
  echo "Use a disposable database name ending in _test/_dev or starting with bwps_clean_." >&2
  exit 2
fi

if [[ "${CONFIRM_RESET}" != "${DB_NAME}" ]]; then
  echo "Refusing to drop/recreate '${DB_NAME}' without explicit confirmation." >&2
  echo "Run again with: CONFIRM_RESET=${DB_NAME}" >&2
  exit 2
fi

MYSQL_PASSWORD_ARG=()
if [[ -n "${DB_PASSWORD}" ]]; then
  MYSQL_PASSWORD_ARG=("-p${DB_PASSWORD}")
fi

MYSQL=(mysql --protocol=TCP -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "${MYSQL_PASSWORD_ARG[@]}")
MYSQL_DB=(mysql --protocol=TCP -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "${MYSQL_PASSWORD_ARG[@]}" "${DB_NAME}")

required_files=(
  "database/schema/001_base_schema.sql"
  "database/schema/002_keys_auto_increment.sql"
  "database/seeds/001_catalogue_reference.sql"
)

for file in "${required_files[@]}"; do
  if [[ ! -s "${file}" ]]; then
    echo "Required import file missing or empty: ${file}" >&2
    exit 1
  fi
done

echo "Rebuilding disposable database: ${DB_NAME}"
"${MYSQL[@]}" -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "Importing schema..."
"${MYSQL_DB[@]}" < database/schema/001_base_schema.sql
"${MYSQL_DB[@]}" < database/schema/002_keys_auto_increment.sql

echo "Importing catalogue/reference seed..."
"${MYSQL_DB[@]}" < database/seeds/001_catalogue_reference.sql

echo "Running validation..."
DB_HOST="${DB_HOST}" \
DB_PORT="${DB_PORT}" \
DB_USER="${DB_USER}" \
DB_PASSWORD="${DB_PASSWORD}" \
DB_NAME="${DB_NAME}" \
bash tools/validate_clean_database_import.sh

echo "Clean database rebuild completed: ${DB_NAME}"
