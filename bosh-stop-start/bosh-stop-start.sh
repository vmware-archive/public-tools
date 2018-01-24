#!/bin/bash

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

# ---------------------------------------------
# for platform independence
# ---------------------------------------------
REALPATH="realpath"
if [ "$(uname -s)" == "Darwin" ]; then
  REALPATH="readlink -f"
fi
SCRIPTDIR=$(dirname $(${REALPATH} $0))

OM=${SCRIPTDIR}/om-linux
JQ=${SCRIPTDIR}/jq-linux64
if [ "$(uname -s)" == "Darwin" ]; then
  OM=${SCRIPTDIR}/om-darwin
  JQ=${SCRIPTDIR}/jq-osx-amd64
fi
# ---------------------------------------------

printline "Operation starting"
echo

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
LOGDIR=${SCRIPTDIR}/logs
LOGFILE=${LOGDIR}/out-${TIMESTAMP}.log
printline "Log will be created here: ${LOGFILE}"
echo
mkdir -p ${LOGDIR}

BOSH_AUTHENTICATED=$( \
  ${OM} -k -t ${OPSMAN_URL} -u ${OPSMAN_USER} -p ${OPSMAN_PASSWD} \
    curl -s -p /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
  ${JQ} ".credential" --raw-output \
)

mkdir -p ${LOGDIR}
for DEPLOYMENT in $(eval ${BOSH_AUTHENTICATED} deployments | awk '{print $1}' | grep -v '\/'); do
  printline "processing $DEPLOYMENT"
  eval ${BOSH_AUTHENTICATED} -d ${DEPLOYMENT} stop --hard --non-interactive 2>&1 | tee -a ${LOGFILE}
done

printline "Operation complete"