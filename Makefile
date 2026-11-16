-include .env
export

HOOK ?= webhook-test
LEAD ?= fixtures/leads/hot.json

.PHONY: env up down logs ps export import psql lead leads

env:
	@if [ -f .env ]; then echo ".env already exists, left untouched"; else \
	  sed -e "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$$(openssl rand -hex 16)/" \
	      -e "s/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$$(openssl rand -hex 32)/" \
	      .env.example > .env && echo "Created .env with random secrets"; fi

up:
	docker compose up -d
	@echo "n8n:     http://localhost:5678"
	@echo "Adminer: http://localhost:8080  (server: postgres, user: $(POSTGRES_USER), db: leads)"

down:
	docker compose down

logs:
	docker compose logs -f n8n

ps:
	docker compose ps

export:
	docker compose exec n8n n8n export:workflow --all --separate --pretty --output=/workflows

import:
	docker compose exec n8n n8n import:workflow --separate --input=/workflows

psql:
	docker compose exec postgres psql -U $(POSTGRES_USER) -d leads

lead:
	@curl -sS -X POST http://localhost:5678/$(HOOK)/lead -H 'Content-Type: application/json' --data @$(LEAD); echo

leads:
	@for f in fixtures/leads/*.json; do echo "--> $$f"; $(MAKE) -s lead LEAD=$$f HOOK=$(HOOK); done
