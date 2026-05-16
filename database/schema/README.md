# Schema Files

This folder will hold SQL files that define the database structure only.

Future schema files should include:

- `CREATE TABLE` statements
- primary keys
- secondary indexes
- auto-increment rules
- safe compatibility comments where needed

Future schema files should not include:

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
002_indexes.sql
003_compatibility_views.sql
```

## Compatibility approach

This rewrite is still tied to legacy PHP endpoints. Keep the old table and column names until the code has been modernised enough to support migrations safely.

That means awkward legacy names can be documented first, then renamed later behind compatibility wrappers or code updates.
