# Glossary

**leads-dont-sleep**: the automation layer that takes Client A's leads from every channel to a clean, synced, watched record.

- **Client A**: the fictional Kyiv residential developer, shared with `no-lead-left-behind`.
- **Lead**: one buyer's request, from any source (website form, ads, partner import, call).
- **Intake**: the workflow that receives a lead, cleans it, enriches it and stores it.
- **Temperature**: the AI's label for a lead: `hot` (ready, budget fits, soon), `warm`, `cold`, or `unclassified` when the AI failed.
- **Item**: one JSON object flowing through n8n; most nodes run once per item.
- **Execution**: one run of a workflow, kept in n8n's log with its data.
- **Credential**: a secret stored encrypted inside n8n, referenced by workflows by id.
- **Test URL / production URL**: n8n's two webhook addresses: `/webhook-test/` listens only while you test in the editor; `/webhook/` only while the workflow is active.
- **Upsert**: insert a row, or update it if the unique key already exists.
- **Idempotent**: running it twice has the same effect as once.
- **Dead letter**: a lead that failed every retry, parked in a table with its error until replay.
- **Replay**: re-running dead letters once the cause is fixed.
- **Watermark**: the last `updated_at` a sync has seen; the next sync starts from it.
- **Source of truth**: the system whose value wins for a given field.
- **Reconciliation**: a check that two systems hold the same records, reporting the drift.
- **Operation** (Make): one module run on one bundle; Make bills per operation.
