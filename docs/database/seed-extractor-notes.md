# Seed Extractor Notes

## phpMyAdmin comment handling

The legacy `bwps.sql` dump uses phpMyAdmin-style comments before some data blocks:

```sql
--
-- Dumping data for table `example`
--

INSERT INTO `example` ...;
```

The first seed extraction manifest was useful, but the extractor was too strict: it only counted an `INSERT` block when the split SQL chunk started directly with `INSERT`.

That can under-count real seed data when comment lines appear immediately before the `INSERT`.

The extractor now strips leading SQL comments before checking whether a chunk is an `INSERT INTO` statement.

Supported leading comments:

- `-- comment`
- `# comment`
- `/* comment */`

## Safety rule remains unchanged

The parser fix does not loosen the blocked-table policy.

Known player/runtime tables are still refused if requested directly, including:

- `users`
- `buddylist`
- `weevilitems`
- `weevilhats`
- `game-logs`
- `game-rewards`
- player progress/state tables

## Required follow-up

After this parser fix lands, regenerate the seed manifest before creating actual seed SQL.

Do not rely on the previous manifest for final seed export decisions.
