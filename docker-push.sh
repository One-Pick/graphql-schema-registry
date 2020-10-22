#!/bin/bash

export SOURCE_TAG="graphql-schema-registry"
aws ecr get-login-password | docker login --username AWS --password-stdin 509575629265.dkr.ecr.us-east-2.amazonaws.com

./_scripts/push.sh \
  --docker-registry=509575629265.dkr.ecr.us-east-2.amazonaws.com/onepick/graphql-schema-registry \
  --version-tag=dev \
  --latest

export SOURCE_TAG=''