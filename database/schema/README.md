# Schema Files

This folder will hold SQL files that define the database structure only.

Schema files should include:

- `CREATE TABLE` statements
- primary keys
- secondary indexes
- auto-increment rules
- safe compatibility comments where needed

Schema files should not include:

- user records
- player inventories
- buddy lists
- logs
- game-world catalogue inserts
- session or login keys
- IP addresses

## Naming convention

Use numbered files so imports are deterministic:

```text
001_base_schema.sql
002_keys_auto_increment.sql
003_compatibility_views.sql
```

## Extraction tool

The schema export is generated from the root legacy dump with:

```bash
python tools/extract_schema_from_dump.py --input bwps.sql --output-dir database/schema
```

The tool writes:

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
```

`001_base_schema.sql` contains table definitions only.

`002_keys_auto_increment.sql` contains `ALTER TABLE` statements for keys, indexes, and auto-increment rules.

`schema_manifest.md` records the extracted table count and table names.

## Compatibility approach

This rewrite is still tied to legacy PHP endpoints. Keep the old table and column names until the code has been modernised enough to support migrations safely.

That means awkward legacy names can be documented first, then renamed later behind compatibility wrappers or code updates.

## Important casing warning

The PHP audit found mixed-case table usage in the legacy runtime, while the SQL dump mostly uses lowercase names.

Before deploying this schema to Linux/MariaDB, test table-name case behaviour carefully. Do not normalise table names until all PHP queries are mapped and updated together.
