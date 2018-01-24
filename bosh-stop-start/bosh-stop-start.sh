#!/bin/bash

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

# for platform independence
READLINK_BIN="readlink -f"
OM_BIN=om-linux
JQ_BIN=jq-linux64
if [ "$(uname -s)" == "Darwin" ]; then
  READLINK_BIN="realpath"
  OM_BIN=om-darwin
  JQ_BIN=jq-osx-amd64
fi

SCRIPTDIR=$(dirname $(${READLINK_BIN} $0))
OM=${SCRIPTDIR}/${OM_BIN}
JQ=${SCRIPTDIR}/${JQ_BIN}

printline "Operation starting"
echo

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
LOGDIR=${SCRIPTDIR}/logs
LOGFILE=${LOGDIR}/out-${TIMESTAMP}.log
printline "Log will be created here: ${LOGFILE}"
echo
mkdir -p ${LOGDIR}

printline "Acquiring BOSH credentials from Ops Manager"
BOSH_AUTH="$( \
  ${OM} -k -t ${OPSMAN_URL} -u ${OPSMAN_USER} -p ${OPSMAN_PASSWD} \
    curl -s -p /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
  ${JQ} ".credential" --raw-output |
  sed "s/ bosh //"\
)"
eval ${BOSH_AUTH} # extract vars

printline "Testing BOSH connectivity at ${BOSH_ENVIRONMENT}:25555"
if ! nc -z ${BOSH_ENVIRONMENT} 25555 -w 5 2>&1 > /dev/null; then
  echo "Aborting.  BOSH director unreachable.  Ensure script is run from the Ops Manager VM."
  exit 1
fi

printline "Discovering deployments"
mkdir -p ${LOGDIR}
for DEPLOYMENT in $(eval ${BOSH_AUTHENTICATED} deployments | awk '{print $1}' | grep -v '\/'); do
  eval ${BOSH_AUTHENTICATED} -d ${DEPLOYMENT} stop --hard --non-interactive 2>&1 | tee -a ${LOGFILE}
done

printline "Operation complete"