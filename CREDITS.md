# Credits

This project is a modern rewrite and preservation-focused rebuild of an older Bin Weevils community server codebase.

## Original Project Credit

Credit for the original Bin Weevils Private Server / Bin Weevils Rewritten work belongs to:

- Smiley / Darkk
- HDWEEVIL
- KnowYourKnot for the public reference repository

Original reference repo:

https://github.com/KnowYourKnot/Binweevils

This rewrite exists because that work was made public and preserved.

## Security and Testing Credit

Thanks to CoDCrafted for finding and flagging the session-key exploit class that was fixed during the Phase 5 security hardening passes.

That report helped confirm the need to rotate session/login keys on logout and reject blank usernames or blank session keys inside the session checker.

## Original Game and Rights Holders

Bin Weevils, its characters, branding, artwork, names, logos, and related assets belong to their original rights holders.

This project is unofficial and is not affiliated with Bin Weevils, 55 Pixels, Nickelodeon, or any original rights holders.

## Rewrite Work

This repository is being maintained as a separate modern rewrite and cleanup project.

The rewrite focuses on documentation, safer setup, cleaner config handling, database cleanup, modern developer workflow, compatibility-preserving backend cleanup, security hardening, progression fixes, and optional launcher/browser improvements.

## Data Cleanup Note

Old staff names, moderator names, demo accounts, test users, and old account records inside runtime files are not project credit.

Those entries may be removed, replaced, or sanitised as part of the rewrite.

Credits and source attribution stay in docs. Old runtime data gets cleaned from code, configs, and database seeds.

## Forking Notice

If you fork or build from this repository, keep attribution to the original project, this rewrite project, and credited security/testing contributors where relevant.
