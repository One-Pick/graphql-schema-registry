START_TIME=$(date +%s)

CURR_DIR=$(pwd)

usage() {
    echo "Usage: dockerize.sh [ --revision REVISION ]                         
        Revision info should be put at build time for traceability
    "
}

PARSED_ARGUMENTS=$(getopt -a -n push -o revision: --long revision:,dockerfile: --long dockerfile: -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

# echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :; do
    case "$1" in
    -revision | --revision)
        REVISION="$2"
        shift 2
        ;;
    -dockerfile | --dockerfile)
        DOCKERFILE="$2"
        shift 2
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
        exit 2
        ;;
    esac
done

usage # Print help

if [ -z $DOCKERFILE ]; then
    DOCKERFILE='Dockerfile'
fi

# REVISION=${1}
BUILD_TIME="$(date -u)"
echo "DOCKERFILE=${DOCKERFILE}"
echo "REVISION=${REVISION}"
echo "BUILD_TIME=${BUILD_TIME}"
echo "SOURCE_TAG=${SOURCE_TAG}"

if [ -z $SOURCE_TAG ]; then
    echo "ERROR: Must set SOURCE_TAG environment before building docker"
    exit 1
fi

docker build -t ${SOURCE_TAG} --build-arg REVISION="${REVISION}" --build-arg BUILD_TIME="${BUILD_TIME}" -f "${CURR_DIR}/${DOCKERFILE}" ${CURR_DIR}

END_TIME=$(date +%s)

echo "Took: $((END_TIME - START_TIME)) second(s)"
