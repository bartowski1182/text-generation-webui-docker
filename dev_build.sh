#!/bin/bash

docker build --build-arg CACHEBUST=$(date +%s) --build-arg clone_arg="--branch dev" -t noneabove1182/text-gen-ui-gpu .
