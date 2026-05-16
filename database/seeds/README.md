# Seed Files

This folder will hold safe default data for a fresh local/private server install.

Seed files should be reviewed before import. The aim is to keep game-world content while avoiding old account and moderation data.

## Good seed candidates

These are likely to become seed files after the dump is split and tested:

- apparel types
- item catalogue data
- garden item catalogue data
- levels
- puzzle definitions
- quest/task definitions
- track/game definitions
- clean default nest/room templates

## Bad seed candidates

These should not be imported by default:

- old `users` rows
- plaintext password values
- session/login keys
- IP address fields
- old `buddylist` rows
- old player inventory/progress rows
- old moderation/admin logs
- old staff or celebrity account identity records

## Demo data rule

Demo data should be obvious and disposable.

Good examples:

- `demo_admin`
- `demo_weevil`
- `local_test_user`

Bad examples:

- old private-server usernames
- old moderator names
- old celebrity/staff names
- copied accounts from the dump

## Import order later

Once split, a clean install should run roughly like this:

1. schema files
2. catalog/world seed files
3. local setup script for admin/demo accounts
4. optional development fixtures
