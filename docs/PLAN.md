# Plan

## Purpose

Client A (the Kyiv developer from `no-lead-left-behind`) already has an AI agent that qualifies buyers in Telegram. What it lacks is the plumbing around it: leads arrive from a website form, ads and partner imports, half of them dirty or duplicated, the CRM and the database disagree, and when something fails at 3am nobody knows. This repo builds that layer, the way an Automation Specialist would for a paying client.

It must also prove the target role, line by line:

| Job requirement | Where this repo proves it |
|---|---|
| Analyse processes, gather requirements | Step 0 pitch, step 8 case study, `/client` drills |
| Make, n8n, Zapier, AI tools | Steps 2, 6; AI extraction in step 2 |
| API and webhook integrations between CRM and others | Steps 2, 3 |
| Python when low-code is not enough | Step 5 |
| PostgreSQL, SQL, data sync | Steps 2, 4 |
| Monitor, troubleshoot, scale | Steps 3, 7 |

Riddle lists below have no answers on purpose: Claude asks them, Taras guesses, the system judges.

## Steps

### Step 0. Interview sprint (2 hours, before the Glorium interview)

Run `/sprint`. A thin slice, built fast; depth comes later.

- 0:00–0:10 `make env && make up`, owner account, Anthropic and Telegram credentials.
- 0:10–0:55 Intake v0 in the UI: Webhook `/lead` → Edit Fields (trim, lowercase email) → IF (has phone or email) → Information Extractor (Anthropic, `claude-haiku-5-5`): `budget_usd`, `rooms`, `timing`, `temperature` hot/warm/cold, error output to an `unclassified` branch → Switch on temperature → Telegram → Respond to Webhook.
- 0:55–1:10 Make vocabulary: scenario, module, router, iterator, aggregator, operation. Look, do not build.
- 1:10–1:45 Interview drill: 8 questions answered through intake v0, then `/interview`.
- 1:45–2:00 The 90-second pitch in English: project 1 (agent, evals, 293/300), project 2 (this one), why Python there and n8n here.

Riddles: How many executions does one `curl` create? `make lead` works, then you switch the workflow to Active and it returns 404: why? You send `batch.json` (3 leads): how many Telegram messages? The LLM times out: what does the client see, and what do you want them to see? Where in n8n do you look first when a lead "disappeared"?

Done when: `make leads` sends all fixtures and each lands in the right branch, and he gives the pitch without notes.

### Step 1. Lab hardening (1h)

The compose stack exists. Make it his: he must explain every line.

Riddles: You delete the `n8n_data` volume but keep Postgres. What survives, what is lost? You change `N8N_ENCRYPTION_KEY` in `.env` and restart. What breaks first? Inside the n8n container, `http://localhost:5432` fails: why, and what is the right host? Why run n8n on Postgres and not the default SQLite for a client?

Build (Claude): pin `N8N_VERSION` to the version `docker compose exec n8n n8n --version` prints. Add `make backup` (pg_dump + key reminder).

Done when: he can draw the stack (3 containers, 2 volumes, 1 network) from memory and answer the four riddles.

### Step 2. Intake v1: clean, enrich, store, notify (2h)

Build (Taras): the `leads` table (he designs it: which column is unique and why), normalisation of phone to E.164, upsert by contact, AI extraction, Telegram alert for hot leads only, one Slack-style digest for the rest. Handle `batch.json` (Split Out). Respond to Webhook fast with the lead id.

Riddles: `messy.json` arrives after `hot.json`: one lead or two in the table, and which fields win? Same email, different case and spaces: what makes Postgres treat them as equal? 20 leads in one minute: how do you send one digest, not 20 messages? Code node or Edit Fields for phone normalisation, and what does each cost the next maintainer? The LLM returns `"budget": "85k"` instead of a number: where do you catch it?

Done when: running `make leads` twice leaves the table with no duplicates, and a broken LLM key sends leads to `unclassified` instead of losing them.

### Step 3. Mock CRM and reliability (2.5h)

Build (Claude): `crm/` FastAPI mock CRM with a Dockerfile and three knobs: rate limit (429 with `Retry-After`), random 5xx, duplicate webhooks. HMAC signing of its outgoing webhooks.
Build (Taras): push leads to the CRM with retry and backoff; a `processed_events` dedup table; HMAC check on incoming CRM webhooks; a global Error Workflow to Telegram (workflow, execution id, error, link); a `dead_letter` table and a replay workflow.

Riddles: The CRM webhook arrives twice: what happens to the lead, and which table stops it? Retrying a POST created two contacts: why, and what header fixes it on the server side? 429 vs 500 vs 400: which do you retry, and how long do you wait? The CRM is down for 10 minutes: where are those leads, and how do they get back? Why answer the webhook with 200 before processing?

Boss fight: `/chaos` with all three knobs on.
Done when: after a 10-minute CRM outage, replay restores every lead and nothing is duplicated.

### Step 4. CRM ↔ Postgres sync (1.5h)

Build (Taras): incremental pull from the CRM with an `updated_at` watermark (`sync_state` table), cursor pagination, last-write-wins upsert, field ownership (CRM owns `stage`, our DB owns the AI fields), a nightly reconciliation query (anti-join both ways) that reports drift to Telegram.

Riddles: Offset pagination while new contacts are being added: what goes wrong? A contact is edited in both systems in the same minute: who wins, and why that rule? Why `>=` and not `>` on the watermark, and what does it force you to handle? Write the query that finds leads in our DB missing in the CRM.

Done when: he writes upsert, dedup (`ROW_NUMBER`) and the anti-join from memory, and the reconciliation report shows 0 drift.

### Step 5. Python where low-code stops (1h)

Build (Claude, Taras reviews): `services/dedup/`, a FastAPI service with pytest: fuzzy duplicate detection (same buyer, different email, similar name and phone), called from n8n through HTTP Request. Taras writes `docs/adr/0001-python-service-vs-code-node.md`.

Riddles: 25 lines of pure transformation: Code node or service? Which three signs say "move it out of n8n"? Who maintains the service after you leave, and what does that cost the client?

Done when: he defends the ADR in 60 seconds.

### Step 6. The same intake in Make (1h)

Build (Taras): intake v0 in Make (free tier): webhook, router, iterator for `batch.json`, HTTP to the AI, Google Sheet or webhook out. Write `docs/tool-comparison.md`: operations per lead in Make vs one execution in n8n, error handling, self-hosting and GDPR.

Riddles: `batch.json` with 3 leads through 6 modules: how many operations? Where does Make retry, and where does n8n? A French client with health data: which tool, and why?

Done when: the comparison has real numbers from his two builds.

### Step 7. Watching 50 workflows (1h)

Build (Taras): an `executions_log` table fed by a sub-workflow, a daily health digest (success rate, slowest workflow), a heartbeat check that alerts when a scheduled workflow did not run.

Riddles: A scheduled workflow silently stopped: what notices, and how fast? Error Workflow vs heartbeat: what does each catch that the other misses? What changes at 50 workflows and 10k executions a day (queue mode, pruning)?

Done when: a disabled scheduled workflow raises an alert within 15 minutes.

### Step 8. Portfolio packaging (1.5h)

Build (Claude drafts, Taras edits): README in the style of `no-lead-left-behind`: problem, before/after table, mermaid diagram, demo GIF, "what breaks at 10x", limits, run commands. A 90-second case study pitch, in English and French.

Done when: a stranger can clone, run `make env && make up && make import`, and see a lead flow in under 10 minutes.
