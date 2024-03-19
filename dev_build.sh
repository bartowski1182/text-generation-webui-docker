#!/bin/bash

docker build --build-arg CACHEBUST=$(date +%s) --build-arg clone_arg="--branch gradio4" -t text-gen-ui-gpu .
