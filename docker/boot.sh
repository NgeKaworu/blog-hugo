#!/bin/bash
set -e

docker pull ngekaworu/blog-hugo;

docker compose -f ./docker-compose.yml -p blog-hugo up -d;
