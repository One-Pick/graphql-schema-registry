#!/bin/bash

START_TIME=$(date +%s)

CURR_DIR=$(pwd)

usage() {
    echo "Usage: push.sh [ --docker-registry DOCKER_REGISTRY ]
                         [ --docker-username DOCKER_USERNAME ]
                         [ --docker-password DOCKER_PASSWORD ]
                         [ --version-tag VERSION_TAG ]
                         [ --build-number BUILD_NUMBER ]
                         [ --latest ]
        DOCKER_USERNAME, DOCKER_PASSWORD could be set via environment variables
    "
}

PARSED_ARGUMENTS=$(getopt -a -n push -o dr:,du,dp,bn --long docker-registry:,docker-username:,docker-password:,build-number:,version-tag:,latest -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
    exit 1
fi

# echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :; do
    case "$1" in
    --docker-registry)
        DOCKER_REGISTRY="$2"
        shift 2
        ;;
    --docker-username)
        DOCKER_USERNAME="$2"
        shift 2
        ;;
    --docker-password)
        DOCKER_PASSWORD="$2"
        shift 2
        ;;
    --build-number)
        BUILD_NUMBER="$2"
        shift 2
        ;;
    --version-tag)
        VERSION_TAG="$2"
        shift 2
        ;;
    --latest)
        IS_LATEST=true
        shift 1
        ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --)
        shift
        break
        ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *)
        echo "Unexpected option: $1 - this should not happen."
        usage
        exit 1
        ;;
    esac
done

usage

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "Please provide --docker-registry"
    exit 1
fi

echo "DOCKER_REGISTRY=$DOCKER_REGISTRY"
echo "VERSION_TAG=$VERSION_TAG"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "SOURCE_TAG=$SOURCE_TAG"

if [ -z $SOURCE_TAG ]; then
    echo "ERROR: Must set SOURCE_TAG environment before building docker"
    exit 1
fi

if [[ (-z "${DOCKER_USERNAME}") && (-z "${DOCKER_PASSWORD}") ]]; then
    :
else
    echo "=> Login registry. If already login, press Return to continue"
    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} ${DOCKER_REGISTRY}
fi

echo "=> Read app version"
VERSION=$(cat ${CURR_DIR}/package.json |
    grep version |
    head -1 |
    awk -F: '{ print $2 }' |
    sed 's/[",]//g' |
    tr -d '[[:space:]]')

if [ -z "${VERSION}" ]; then
    echo "Could not parse VERSION from package.json"
    exit 1
fi

echo "=> Make current tag"
DOCKER_TAG="${DOCKER_REGISTRY}:${VERSION}"
LATEST_TAG="${DOCKER_REGISTRY}:latest"
if [ ! -z "${VERSION_TAG}" ]; then 
    DOCKER_TAG="$DOCKER_TAG.${VERSION_TAG}"
    LATEST_TAG="${LATEST_TAG}.${VERSION_TAG}"
fi

echo "DOCKER_TAG=${DOCKER_TAG}"

echo "=> Push current tag"
docker tag ${SOURCE_TAG} ${DOCKER_TAG}
docker push ${DOCKER_TAG}

if [ $IS_LATEST ]; then
    echo "=> Push lastest tag"
    docker tag ${SOURCE_TAG} ${LATEST_TAG}
    docker push ${LATEST_TAG}
fi

if [ -z "${BUILD_NUMBER}" ]; then
    :
else
    echo "=> Make unique tag"
    UNIQUE_TAG="${DOCKER_TAG}-${BUILD_NUMBER}"
    echo "UNIQUE_TAG=${UNIQUE_TAG}"

    docker tag ${SOURCE_TAG} ${UNIQUE_TAG}

    docker tag ${UNIQUE_TAG} 509575629265.dkr.ecr.us-east-2.amazonaws.com/onepick/graphql-schema-registry:latest


    echo "=> Push unique tag"
    docker push ${UNIQUE_TAG}
fi

END_TIME=$(date +%s)

echo "Took: $((END_TIME - START_TIME)) second(s)"
