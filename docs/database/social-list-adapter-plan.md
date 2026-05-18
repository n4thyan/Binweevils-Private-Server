# Social List Adapter Plan

This is the first focused plan for replacing the old packed buddy/list storage without breaking the legacy Flash/PHP runtime.

## Current legacy table

The current clean schema keeps the old `buddylist` table shape for compatibility:

```text
buddylist
- id
- ownerName
- namesList
- blockList
- requestList
```

Current problems:

- `ownerName` is a username string, not a stable numeric user ID.
- `namesList`, `blockList`, and `requestList` are packed list strings.
- Relationship rows cannot be indexed, validated, moderated, or cleaned easily.
- Renames/case mismatches can break relationships.
- It is hard to tell who requested whom without parsing strings.

## Adapter-first rule

Do not replace `buddylist` directly yet.

For now:

```text
old table stays as source of truth
adapter parses old packed strings
new code can see relationship-shaped data
old SWF-facing endpoints keep old output
```

## Read-only adapter target

The first adapter only reads old data.

It should safely expose:

```text
owner_user_id
owner_username
buddies[]
blocked[]
requests[]
```

Each parsed relationship should look like:

```text
owner_user_id
owner_username
target_user_id, nullable while old data is messy
target_username
relation_type
status
```

Suggested relation types:

```text
buddy
blocked
request
```

Suggested statuses:

```text
accepted
blocked
pending
```

## Parser safety rules

Packed list parsing should:

- trim whitespace
- ignore empty entries
- de-duplicate repeated names case-insensitively
- preserve the original target username casing for legacy output
- avoid writing cleaned values back yet
- tolerate missing users by returning `target_user_id = null`

Do not kick, delete, or auto-repair old social data during read-only parsing.

## Future clean table

Later, add a clean table beside `buddylist`:

```text
user_social_links
- id
- owner_user_id
- target_user_id
- relation_type
- status
- created_at
- updated_at
```

Recommended constraints later, after write flow is understood:

```text
unique(owner_user_id, target_user_id, relation_type)
index(owner_user_id)
index(target_user_id)
index(relation_type, status)
```

Do not add aggressive foreign keys until account deletion, rename, local seed, and admin cleanup behaviour is mapped.

## Future migration path

Suggested order:

1. Add read-only parser helper.
2. Add clean table migration beside old table.
3. Backfill local/dev data only.
4. Dual-write one safe relation type.
5. Keep reads from old table until dual-write is proven.
6. Move reads behind adapter.
7. Keep old SWF output shape unchanged.
8. Only later consider old table cleanup.

## Do not do yet

- Do not delete `buddylist`.
- Do not rename `ownerName`.
- Do not rewrite `namesList` automatically.
- Do not make the SWF consume the clean table directly.
- Do not assume every name in packed lists still exists in `users`.
- Do not enforce foreign keys until messy legacy data has been audited.
