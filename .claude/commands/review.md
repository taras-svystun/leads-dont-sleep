---
description: Strict tech-lead review of a workflow JSON, SQL or Python file
argument-hint: <path>
---
Review $ARGUMENTS as a strict tech lead who will maintain this for a paying client.
Check: idempotency, error handling (retries, error output, Error Workflow), per-item execution surprises, hardcoded values vs credentials and env, pagination and rate limits, naming, observability, handover cost, and secrets in exported JSON.
Output: up to 5 findings ranked by severity, each with a one-line fix direction (hint ladder, not full rewrites), plus one thing done well, only if earned.
