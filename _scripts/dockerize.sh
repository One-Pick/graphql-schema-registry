START_TIME=$(date +%s)

SCRIPT_DIR=$(
    cd $(dirname "$0")
    pwd
)

usage() {
    echo "Usage: dockerize.sh [ --revision REVISION ]                         
        Revision info should be put at build time for traceability
    "
}

PARSED_ARGUMENTS=$(getopt -a -n push -o revision: --long revision: -- "$@")
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

# REVISION=${1}
BUILD_TIME="$(date -u)"
echo "REVISION=${REVISION}"
echo "BUILD_TIME=${BUILD_TIME}"
echo "SOURCE_TAG=${SOURCE_TAG}"

if [ -z $SOURCE_TAG ]; then
    echo "Must set SOURCE_TAG environment before building docker"
    exit 1
fi

docker build -t ${SOURCE_TAG} --build-arg REVISION="${REVISION}" --build-arg BUILD_TIME="${BUILD_TIME}" -f ${SCRIPT_DIR}/../Dockerfile ${SCRIPT_DIR}/..

END_TIME=$(date +%s)

echo "Took: $((END_TIME - START_TIME)) second(s)"
