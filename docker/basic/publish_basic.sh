#!/bin/bash
set -e

docker build -f Dockerfile.basic -t ngekaworu/basic-hugo .;
docker push ngekaworu/basic-hugo;