.PHONY: default
default:
	@echo "Development:"
	@echo "  make deps   -- Install dependencies"
	@echo "  make graphs -- Compile Mermaid graphs"
	@echo "  make sync   -- Synchronize local cookbook to remote server"
	@echo "  make deploy -- Deploy pipelines on remote server"

.PHONY: deps
deps:
	yarn

.PHONY: graphs
graphs: $(wildcard img/*.mmd.svg)

img/%.mmd.svg: img/%.mmd
	npx mmdc -i $< -o $@

SSH_USERNAME ?= root
SSH_HOST ?= placeholder.example.com
SSH_WORKDIR ?= cookbook

.PHONY: sync
sync:
	rsync --recursive --delete --exclude node_modules . $(SSH_USERNAME)@$(SSH_HOST):$(SSH_WORKDIR)

.PHONY: deploy
deploy: sync
	ssh -t $(SSH_USERNAME)@$(SSH_HOST) "pushd $(SSH_WORKDIR)/ingest; docker compose pull; docker compose up -d"
	ssh -t $(SSH_USERNAME)@$(SSH_HOST) "pushd $(SSH_WORKDIR)/process; docker compose pull; docker compose up -d"
	ssh -t $(SSH_USERNAME)@$(SSH_HOST) "pushd $(SSH_WORKDIR)/process-clickhouse; docker compose pull; docker compose up -d"
