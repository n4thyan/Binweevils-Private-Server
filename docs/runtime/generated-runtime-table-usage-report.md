# Generated Runtime Table Usage Report

This document records where the generated runtime table-usage audit should be stored when a maintainer wants a committed snapshot rather than only a CI artifact.

The canonical generator is:

```bash
python tools/audit_runtime_table_usage.py --output docs/runtime/generated-runtime-table-usage-report.md
```

For now, the workflow uploads the generated report as a GitHub Actions artifact named `runtime-table-usage-report`. That keeps generated output reviewable without forcing noisy commits every time PHP, Node, or schema-adjacent runtime files move.

## Why this exists

Phase 5 is preparing the runtime/database layer for safer local bootstrapping and later schema modernisation.

Before changing auth, account creation, buddy-list bootstrap, nest bootstrap, or inventory bootstrap, we need a reliable map of which runtime files still touch which legacy tables.

## Important boundary

This report is audit/tooling support only. It must not be treated as a replacement for the source scanner or the runtime code itself.

No account data, passwords, session keys, SQL dumps, fixtures, or production state should be committed here.
