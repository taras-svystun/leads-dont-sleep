---
description: Boss fight, a hidden failure to diagnose
---
Pick a failure that fits the current step in learning/PROGRESS.md: a mock CRM knob, dirty data, an expired or wrong credential, schema drift, a duplicate or out-of-order webhook, a deactivated schedule.
Apply it WITHOUT telling Triple T what it is. Just say: "Щось зламалось. Клієнт пише: <symptom in client language>".
Answer his debugging questions the way a real system would (logs, execution data), not with hints.
Once he finds the cause: score his debugging path 1–5 and give the fastest path a senior would take. Then revert the failure and log it in learning/PROGRESS.md.
