#!/bin/bash

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

# for platform independence
REALPATH="realpath"
if ! which ${REALPATH} > /dev/null ; then
  REALPATH="readlink -f"
fi

SCRIPTDIR=$(dirname $(${REALPATH} $0))

printline "Operation starting"
echo

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
LOGDIR=${SCRIPTDIR}/logs
LOGFILE=${LOGDIR}/out-${TIMESTAMP}.log
printline "Log will be created here: ${LOGFILE}"
echo

OM=${SCRIPTDIR}/om-linux
JQ=${SCRIPTDIR}/jq-linux64
if [ "$(uname -s)" == "Darwin" ]; then
  OM=${SCRIPTDIR}/om-darwin
  JQ=${SCRIPTDIR}/jq-osx-amd64
fi

BOSH_AUTHENTICATED=$( \
  ${OM} -k -t ${OPSMAN_URL} -u ${OPSMAN_USER} -p ${OPSMAN_PASSWD} \
    curl -s -p /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
  ${JQ} ".credential" --raw-output \
)

${BOSH_AUTHENTICATED} deployments | awk '{print $1}' | grep -v '\/'

exit 1
# TODO loop around the deployments calling stop --hard

mkdir -p ${LOGDIR}
while true # process next file
do
  printline "Processing ${1-/dev/stdin}"
  while read LINE # process next line
  do
    LINE=$(echo ${LINE} | sed "s/^ *//g" | tr -s " ") # trim the line
    if [ ${#LINE} -eq 0 ]; then # ignore blank lines
      continue
    fi
    if echo ${LINE} | grep -q "^#"; then # ignore commented lines
      continue
    fi

    # TODO LOOP HERE ??? ...

  done < "${1:-/dev/stdin}" # process next line of $1 or STDIN

  # shift to next arg (if any), and break id we're at zero args
  shift
  if [ $# -eq 0 ]; then
    break
  fi

done

printline "Operation complete"