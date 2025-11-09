#!/bin/bash

source config.env
docker compose -f docker-compose.yml up -d --force-recreate
docker compose -f docker-compose.yml logs -f