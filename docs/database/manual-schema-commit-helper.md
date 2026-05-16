# Manual Schema Commit Helper

This note explains why PR #12 uses a manual helper workflow instead of relying on an automatic branch push.

## Why manual

GitHub Actions may not automatically run a workflow that is introduced for the first time on a feature branch. The workflow usually becomes available from the Actions tab after it exists on the default branch.

Because of that, PR #12 now treats the generated schema commit helper as a reusable manual tool.

## Helper workflow

```text
.github/workflows/schema-files-commit.yml
```

The workflow accepts:

```text
target_branch
commit_message
```

Suggested target branch:

```text
database/schema-files
```

The workflow will:

1. check out the selected branch
2. run `tools/extract_schema_from_dump.py`
3. generate the schema files under `database/schema/`
4. verify the generated files exist
5. commit the generated files back to the selected branch

## Generated files

```text
database/schema/001_base_schema.sql
database/schema/002_keys_auto_increment.sql
database/schema/schema_manifest.md
```

## Safe boundaries

The helper does not edit runtime PHP, Node, Electron, or asset files.

It regenerates schema files from `bwps.sql`; it does not modify `bwps.sql` itself.
