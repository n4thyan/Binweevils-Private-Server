# Database Inventory

This file records what is currently visible in the legacy `bwps.sql` dump and how it should be treated during the modern rewrite.

The main rule is simple: content and item catalogue data can often stay, but user/account seed data and unsafe auth patterns should not.

## High-value data to preserve

These areas are useful for keeping the game experience intact:

- item catalogue data
- garden item catalogue data
- apparel catalogue data
- levels and progression tables
- quest/task definitions once cleaned
- game definitions and score metadata
- newspaper/crossword/wordsearch definitions if the client still uses them
- nest room definitions and starter room layout data

These should be treated as game content data, not as trusted application logic.

## Data that needs cleaning before public/dev use

### `users`

The SQL dump currently includes seeded local user rows. These are useful for understanding schema shape, but should not be kept as real default accounts in a modern repo.

Problems to fix:

- plain-text passwords
- static session/login keys
- old local IP values
- old test usernames
- default moderator/admin assumptions are unclear

Rewrite direction:

- keep the table schema only during the legacy phase
- remove seeded user rows from the default import
- add a separate local-only seed script for demo accounts
- hash passwords with a modern password hashing library
- generate session/login keys at runtime
- never commit real user rows, IPs, emails, or session data

### `tycoonbusinesses`

The dump contains starter business rows assigned to old test account names. These should become per-user starter data created during registration or first login, not static rows tied to legacy account names.

Rewrite direction:

- remove account-name-specific seed rows from default import
- create starter businesses from code when a new account is created
- use user IDs rather than usernames where possible

### `weevilitems`

The dump contains at least one starter inventory row tied to a seeded account. This should become starter inventory generated during account creation.

Rewrite direction:

- keep item catalogue definitions
- move starter inventory into a registration/bootstrap routine
- avoid committing account-owned inventory rows in the default SQL

### Quest/task placeholder rows

The dump contains long runs of quest task rows where many fields are `NULL` or zero and `taskType` is `permanent`. These may be historical placeholders, incomplete imports, or client-required IDs.

Rewrite direction:

- do not delete blindly
- split into `schema.sql`, `catalogue_seed.sql`, and `dev_seed.sql`
- mark placeholder-heavy sections for runtime testing before pruning
- keep ID stability until the client protocol is understood

## Suggested SQL split

The single dump should eventually become:

| File | Purpose |
| --- | --- |
| `database/schema.sql` | Tables, indexes, constraints only. No personal/test account data. |
| `database/seeds/catalogue.sql` | Game catalogue content: items, levels, quests, game metadata. |
| `database/seeds/dev.sql` | Optional local demo account and starter inventory. Never production default. |
| `database/migrations/` | Incremental schema changes once the modern backend starts replacing legacy code. |

## Normalisation targets

These are future improvements, not first-pass blockers:

- prefer numeric user IDs over usernames for ownership links
- add unique indexes for usernames and emails where appropriate
- move auth/session fields into their own tables
- add created/updated timestamps consistently
- standardise table naming, especially legacy names with hyphens
- use one charset/collation consistently, ideally `utf8mb4`

## Safety checklist before using the SQL in public docs or production

- Remove seeded users.
- Remove plain-text passwords.
- Remove static session/login keys.
- Remove IP addresses.
- Remove account-specific starter businesses and inventory.
- Keep catalogue IDs stable until client compatibility has been tested.
- Document every data deletion so it is clear whether it was unsafe user data or actual game content.
