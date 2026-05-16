#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
DB_NAME="${DB_NAME:-bwps_clean_test}"

MYSQL=(mysql --protocol=TCP -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "-p${DB_PASSWORD}")
MYSQL_DB=(mysql --protocol=TCP -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "-p${DB_PASSWORD}" "${DB_NAME}")

wait_for_mysql() {
  echo "Waiting for MySQL/MariaDB at ${DB_HOST}:${DB_PORT}..."
  for attempt in {1..60}; do
    if "${MYSQL[@]}" -e "SELECT 1" >/dev/null 2>&1; then
      echo "Database server is ready."
      return 0
    fi
    sleep 2
  done

  echo "Database server did not become ready in time." >&2
  return 1
}

query_scalar() {
  local sql="$1"
  "${MYSQL_DB[@]}" --batch --skip-column-names -e "${sql}"
}

expect_count() {
  local table="$1"
  local expected="$2"
  local actual
  actual="$(query_scalar "SELECT COUNT(*) FROM \`${table}\`;")"

  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected ${table} to contain ${expected} row(s), got ${actual}." >&2
    return 1
  fi

  echo "OK: ${table} contains ${actual} row(s)."
}

expect_not_empty() {
  local table="$1"
  local actual
  actual="$(query_scalar "SELECT COUNT(*) FROM \`${table}\`;")"

  if [[ "${actual}" == "0" ]]; then
    echo "Expected ${table} to contain catalogue/reference rows, got 0." >&2
    return 1
  fi

  echo "OK: ${table} contains ${actual} row(s)."
}

expect_empty() {
  local table="$1"
  expect_count "${table}" 0
}

main() {
  wait_for_mysql

  echo "Recreating disposable database: ${DB_NAME}"
  "${MYSQL[@]}" -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

  echo "Importing clean schema files..."
  "${MYSQL_DB[@]}" < database/schema/001_base_schema.sql
  "${MYSQL_DB[@]}" < database/schema/002_keys_auto_increment.sql

  echo "Importing catalogue/reference seed file..."
  "${MYSQL_DB[@]}" < database/seeds/001_catalogue_reference.sql

  echo "Checking table count..."
  table_count="$(query_scalar "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE();")"
  if [[ "${table_count}" != "55" ]]; then
    echo "Expected 55 tables, got ${table_count}." >&2
    return 1
  fi
  echo "OK: found ${table_count} tables."

  echo "Checking selected catalogue/reference tables are populated..."
  expect_not_empty itemtype
  expect_not_empty itemtypets
  expect_not_empty appareltypes
  expect_not_empty gardenitemtype
  expect_not_empty seeds
  expect_not_empty puzzletypes
  expect_not_empty crosswords
  expect_not_empty questtasks

  echo "Checking blocked player/runtime tables stayed empty..."
  expect_empty users
  expect_empty buddyalerts
  expect_empty buddylist
  expect_empty nest
  expect_empty nestinfo
  expect_empty weevilitems

  echo "Checking held-back optional data stayed empty..."
  expect_empty tycoonbusinesses

  echo "Clean database import validation passed."
}

main "$@"
