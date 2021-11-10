#!/bin/bash
set -e

docker compose -f ./docker-compose.dev.yml -p blog-hugo-dev up -d --build;