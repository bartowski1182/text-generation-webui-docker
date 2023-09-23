#!/bin/bash

# Load variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

# Use the variable from .env if no argument is passed
if [ "$#" -eq 0 ]; then
    if [ -z "$COMMITHASH" ]; then
        echo "No commit hash provided and none found in .env"
        exit 1
    fi
else
    COMMITHASH=$1
fi

docker build --build-arg commithash=$COMMITHASH -t noneabove1182/text-gen-ui-gpu .
