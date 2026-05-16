#!/usr/bin/env python3
"""
Local account setup stub for the experimental clean database path.

This script is intentionally non-destructive and does not insert accounts yet.
It exists to document the future interface while the legacy auth/runtime flow is
reviewed.
"""

from __future__ import annotations

import argparse
import os
import secrets
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class LocalAccountPlan:
    username: str
    password_env: str
    is_moderator: bool


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Plan creation of a fresh local-only Binweevils account. No database writes are performed yet.'
    )
    parser.add_argument('--database-url', required=True, help='Database URL for a disposable/local database.')
    parser.add_argument('--username', required=True, help='Fresh local account username, e.g. local_admin.')
    parser.add_argument('--password-from-env', required=True, help='Environment variable containing the local password.')
    parser.add_argument('--moderator', action='store_true', help='Plan the account as a local moderator/admin account.')
    parser.add_argument('--execute', action='store_true', help='Reserved for a future implementation. Currently refused.')
    return parser


def validate_plan(plan: LocalAccountPlan) -> list[str]:
    errors: list[str] = []

    if not plan.username.startswith('local_'):
        errors.append('Username must start with local_ while this setup flow is experimental.')

    if plan.password_env not in os.environ:
        errors.append(f'Missing required password environment variable: {plan.password_env}')

    return errors


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    plan = LocalAccountPlan(
        username=args.username,
        password_env=args.password_from_env,
        is_moderator=args.moderator,
    )

    errors = validate_plan(plan)
    if errors:
        for error in errors:
            print(f'ERROR: {error}', file=sys.stderr)
        return 2

    if args.execute:
        print('ERROR: --execute is not implemented yet. Review legacy auth/password handling first.', file=sys.stderr)
        return 3

    print('Local account setup plan validated. No database writes were performed.')
    print(f'Username: {plan.username}')
    print(f'Moderator: {1 if plan.is_moderator else 0}')
    print(f'Password env var: {plan.password_env}')
    print(f'Database URL supplied: {args.database_url}')
    print(f'Generated local sessionKey preview: {secrets.token_hex(16)}')
    print(f'Generated local loginKey preview: {secrets.token_hex(16)}')
    print('Next step: implement database writes after reviewing the PHP login/register flow.')

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
