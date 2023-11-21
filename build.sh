#!/bin/bash

REPO_URL="https://api.github.com/repos/oobabooga/text-generation-webui/commits/main"

LATEST_COMMIT=$(curl -s $REPO_URL | grep 'sha' | cut -d\" -f4 | head -n 1)

echo $LATEST_COMMIT

docker build --build-arg commit="$LATEST_COMMIT" -t noneabove1182/text-gen-ui-gpu .
