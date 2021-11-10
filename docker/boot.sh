#!/bin/bash
set -e

docker pull ngekaworu/blog-hugo;
docker compose -f ./docker-compose.yml --env-file ~/.env -p blog-hugo up -d;
