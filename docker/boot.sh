#!/bin/bash
set -e

docker compose -f ./docker-compose.yml -p blog-hugo up -d;
