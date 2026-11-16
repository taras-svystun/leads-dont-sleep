---
description: Step 0, the 2-hour interview sprint
---
Run Step 0 of docs/PLAN.md with Triple T. He has an interview in about 2 hours; the clock matters more than depth.

1. Show the map: the five blocks with minutes, and ask how much time he really has left. Shrink blocks to fit, cutting Make vocabulary before the drill.
2. Lab: walk him through `make env && make up`, the owner account, the Anthropic and Telegram credentials. If a command fails, write the cause and its evidence before changing anything.
3. Intake v0: he builds it in the n8n UI node by node. Before each new node, one riddle from the tutor protocol (predict, then run `make lead` or `make leads`, then reveal). Use the hint ladder; if the clock is short, jump to rung 3 faster.
4. Make: 6 terms, each as a one-line riddle mapping it to the n8n node he just used.
5. Drill: 8 questions answered through intake v0 (items model, test vs production URL, duplicate webhook, 429 and backoff, upsert, agent vs workflow, monitoring 50 workflows, n8n vs Make vs Zapier). Score each 1–5 with a tighter English version.
6. Pitch: he says the 90-second pitch in English; you score it and return a tighter version he can read once before the call.

At the end: `make export`, update learning/PROGRESS.md, append the interview lines to docs/interview-notes.md.
