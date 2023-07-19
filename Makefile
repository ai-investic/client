SHELL := /bin/bash
.DEFAULT_GOAL = help

COMPOSE = docker compose
FILE = -f docker-compose.yml
EXEC = ${COMPOSE} exec
RUN = ${COMPOSE} run

.PHONY: help
# Show this help message
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help

.PHONY: up
# Kill all containers, rebuild and up them
up: kill
	${COMPOSE} ${FILE} up -d --build

.PHONY: kill
# Kill all containers
kill:
	${COMPOSE} kill $$(docker ps -q) || true

.PHONY: stop
# Stop all containers
stop:
	${COMPOSE} stop

.PHONY: rm
# Remove all containers
rm:
	${COMPOSE} rm -f

.PHONY: sr
# Stop and remove all containers
sr: stop rm

.PHONY: purge
# Stop and remove all containers and prune volumes, networks, containers and images
purge:
	docker stop $$(docker ps -aq)
	docker rm $$(docker ps -aq)
	docker volume prune -f
	docker network prune -f
	docker container prune -f
	docker image prune -f

.PHONY: client
# Enter in client container
client:
	${EXEC} investic-client-service ${SHELL}

.PHONY: logs
# Prompt logs of container
logs:
	docker logs --follow investic-client-container

.PHONY: ps
# List active containers
ps:
	${COMPOSE} ps -a

.PHONY: del-dist
# Delete dist directory
del-dist:
	sudo rm -rf dist/

.PHONY: perm
# Fix permissions of all files
perm:
	sudo chown -R www-data:$(USER) .
	sudo chmod -R g+rwx .
