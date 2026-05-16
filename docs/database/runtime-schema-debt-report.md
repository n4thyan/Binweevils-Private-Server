# Runtime Schema Debt Report

This is the first Phase 5 audit report for the generated schema.

A flagged pattern means review before modernising. It does not mean rewrite the table immediately.

## High-level findings

The schema shows several old private-server and Flash-era patterns:

```text
packed list fields
packed runtime defaults
username/name based relationships
missing exported indexes or foreign keys
TEXT/LONGTEXT used for state/progress
hyphenated table names
numeric column names
account/session fields mixed with player profile state
```

## Buddy list storage

The buddy list table stores relationship state in packed list fields.

Debt:

```text
links by username instead of stable user id
stores multiple relationships inside one text field
hard to index, search, deduplicate, paginate, or enforce
```

Short-term:

```text
keep for compatibility
only create minimum local rows if runtime boot requires them
```

Future:

```text
replace with one row per relationship/request/block
```

## User/player account table

The user table mixes account data, legacy session bridge data, moderation flags, and gameplay profile state.

Debt:

```text
several unrelated responsibilities live in one table
legacy session bridge columns are still runtime-critical
gameplay profile state should eventually move out of the account table
appearance defaults include packed runtime state
```

Short-term:

```text
keep table shape for login/runtime compatibility
add password compatibility before local account writes
keep default seeds empty of user rows
```

Future:

```text
split account, session, profile, currency, appearance, and moderation state
```

## Apparel/inventory tables

Some inventory/apparel tables use username ownership links, mixed placement state, and legacy column names.

Debt:

```text
ownership is inconsistent across tables
inventory and room placement are partly mixed together
one apparel table includes a numeric column name
```

Short-term:

```text
do not seed old rows
review runtime code before renaming columns
only add local starter rows after game boot proves they are required
```

## Nest tables

Nest-related tables include username/string owner links and packed default values for some state fields.

Debt:

```text
owner links are string based
some defaults look encoded rather than relational
nest setup may be required for bootstrapping
```

Short-term:

```text
keep legacy structure for compatibility
create local fixture rows only after endpoint behaviour is confirmed
```

## Progress/state tables

Quest, crossword, wordsearch, achievement, and game-stat progress tables need careful review.

Debt:

```text
some progress/state fields are stored as text blobs
some user references are strings instead of numeric ids
catalogue definitions and player progress must stay separate
```

Short-term:

```text
do not seed old player progress
keep catalogue puzzle/task definitions separate from player progress
```

## Hyphenated table names

Several legacy tables use hyphens in their names.

Debt:

```text
must always be quoted in SQL
easier to break in tooling and generated queries
```

Short-term:

```text
keep legacy names until runtime queries are mapped
```

Future:

```text
rename behind compatibility views or adapters, not by direct breakage
```

## Missing indexes/keys note

The generated key/index export currently contains no real key/index statements.

That means the clean schema path should be treated as structurally compatible, not performance-ready.

## Phase 5 recommendation

Do not start by normalising the schema under the runtime.

Start by mapping endpoint usage:

```text
login/register/game boot tables
buddy/nest/inventory startup dependencies
catalogue read paths
player state write paths
```

Then introduce modern replacement tables gradually.
