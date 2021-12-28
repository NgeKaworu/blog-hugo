#!/bin/bash
set -e

tag=ngekaworu/blog-hugo

docker build --file ./Dockerfile --tag ${tag} ..;
docker push ${tag};