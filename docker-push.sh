#!/bin/bash

export $(grep -v '^#' .env | xargs)

if [ -z ${AWS_REPO_HOST} ]; then
  echo "ERROR: AWS_REPO_HOST is empty. Please set export AWS_REPO_HOST=your_aws_repo_host"
  exit 1
fi

aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_REPO_HOST}

./_scripts/push.sh \
  --docker-registry=${AWS_REPO_HOST}/onepick/${SOURCE_TAG} \
  --version-tag=dev \
  --latest
