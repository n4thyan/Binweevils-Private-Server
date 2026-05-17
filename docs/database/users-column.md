# Users Password Column Capacity

Phase 5 introduced a runtime helper that stores modern PHP `password_hash()` values for new local accounts while still allowing temporary legacy verification during migration.

That means the clean schema must be able to store modern hash strings without truncation.

## Current clean schema

The clean schema defines:

```sql
`password` varchar(255) NOT NULL,
```

This is enough for current PHP `password_hash()` output and gives room for future algorithm metadata.

## Guard script

```text
tools/check_credential_column.py
```

Default usage:

```bash
python tools/check_credential_column.py
```

Expected result:

```text
OK: users.password is varchar(255); minimum required length is 255
```

## CI workflow

```text
.github/workflows/users-column-check.yml
```

The workflow fails if:

```text
database/schema/001_base_schema.sql is missing the users table
users.password is missing
users.password is not varchar(...)
users.password is shorter than varchar(255)
```

## Boundary

This pass does not change runtime code or the database itself.

It only documents and protects the clean schema expectation before local account bootstrap work continues.
