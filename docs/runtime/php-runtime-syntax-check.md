# PHP Runtime Syntax Check

Phase 5 will start touching login, registration, and account bootstrap code.

Before changing runtime auth, this workflow adds a basic PHP syntax safety net.

## Workflow

```text
.github/workflows/php-runtime-syntax-check.yml
```

It runs on pull requests that change PHP files under:

```text
game-full
server
```

## What it checks

The workflow runs:

```bash
php -l path/to/file.php
```

for every PHP file under the legacy runtime folders.

## What it does not check

This is only a syntax check.

It does not connect to the database, run the game, validate login behaviour, or test Flash/PHP endpoint responses.

## Why this is useful

When Phase 5 starts adding password compatibility and local account bootstrap logic, broken PHP syntax should fail in CI before the code is merged.

This keeps auth/runtime changes smaller and safer.
