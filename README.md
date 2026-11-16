# leads-dont-sleep

Leads arrive at 3am, from five channels, half of them dirty. This repo is the automation layer that catches every one: clean, enrich with AI, store, sync with the CRM, alert, and notice when something breaks. Built in n8n, Make and Python on Postgres.

It continues [no-lead-left-behind](https://github.com/taras-svystun/no-lead-left-behind): same fictional client (a Kyiv residential developer), next problem. That repo is the AI agent that talks to buyers; this one is the plumbing around it.

**Status:** in progress. The plan is in [docs/PLAN.md](docs/PLAN.md).

## Run it

Needs Docker with Compose.

```sh
make env       # create .env with random secrets (once)
make up        # n8n on http://localhost:5678, Adminer on http://localhost:8080
make import    # load the workflows from workflows/ into n8n
```

Send test leads to the intake webhook:

```sh
make lead                                  # fixtures/leads/hot.json to the test URL
make lead LEAD=fixtures/leads/messy.json   # any single fixture
make leads                                 # every fixture
make leads HOOK=webhook                    # the production URL (workflow must be active)
```

Other commands:

```sh
make export    # save the workflows from n8n into workflows/
make psql      # SQL shell on the leads database
make logs      # follow the n8n logs
make down      # stop everything (data stays in Docker volumes)
```

## How it was built

Built with Claude Code as a tutor, not a code generator: workflows and SQL by hand, every new idea met first as a riddle to guess, then checked against the running system. The method is in [CLAUDE.md](CLAUDE.md) and [.claude/commands/](.claude/commands/).
