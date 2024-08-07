#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(realpath $0))

cd ${SCRIPT_DIR}

DOCKER_COMPOSE_CMD=
if docker compose --version > /dev/null 2>&1; then
  DOCKER_COMPOSE_CMD="docker compose"
else
  DOCKER_COMPOSE_CMD="docker-compose"
fi

cd ../../chains/cardano
${DOCKER_COMPOSE_CMD} down

cd ../../cardano/gateway
${DOCKER_COMPOSE_CMD} down
