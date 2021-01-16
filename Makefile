DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose
KUBECTL ?= kubectl


all: build

# Docker related commands
up: build-app
	$(DOCKER_COMPOSE) up -d --build

down:
	$(DOCKER_COMPOSE) down

migrate:
	$(DOCKER_COMPOSE) exec web knex migrate:latest
	$(DOCKER_COMPOSE) exec web knex seed:run


# Kubernetes deployment commands

kube-build:
	./scripts/docker-build.sh

kube-deploy-db-dev: 
	./scripts/deploy-db.sh dev

kube-deploy-db-prd: 
	./scripts/deploy-db.sh prd

kube-deploy-node-dev: 
	./scripts/deploy-node.sh dev

kube-deploy-node-prd: 
	./scripts/deploy-node.sh prd

.PHONY: up, down, migrate; kube-build, kube-deploy-db-dev,kube-deploy-db-prd,kube-deploy-node-dev,kube-deploy-node-prd
