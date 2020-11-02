#!/bin/bash

export $(grep -v '^#' .env | xargs)

if [ -z $NPM_TOKEN ]; then
    echo "ERROR: NPM_TOKEN is empty. Please set export NPM_TOKEN=your_npm_token"
    exit 1
fi

./_scripts/dockerize.sh --dockerfile=Dockerfile
