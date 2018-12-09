#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------------
# The script expects an input text file (e.g. pas-accounts.txt) or stdin lines representing an identifier for each user (typically an email)

# sbrin@abc.xyz
# emusk@spacex.com
# amcginlay@pivotal.io
# ... and so on

# The script will result in one PAS SpaceDeveloper user per line, each with their own like-named ORG and a SPACE named "dev".
# For simplicity all users will have their password set to "password"
# --------------------------------------------------------------------------------------------------------------------------------------------------

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)

printline "Operation starting"
echo

if ! which cf > /dev/null ; then
  echo "cf CLI not found.  Go to https://console.run.pivotal.io/tools to install.  Aborting"
  exit 1
fi

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
LOGDIR=${SCRIPTDIR}/logs
LOGFILE=${LOGDIR}/out-${TIMESTAMP}.log
printline "Log will be created here: ${LOGFILE}"
echo

mkdir -p ${LOGDIR}
cf target | tee -a ${LOGFILE}
if [ $? -ne 0 ] ; then
  exit 1 # cf target will speak for itself in this case
fi

echo
echo "If you're not logged in as admin this action will likely fail"
read -p "Are you sure you want to create users using this target?> " -r
echo
if [[ ! $REPLY =~ ^[Yy] ]]
then
    echo "Aborting"
    exit 1
fi

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

    EMAIL=${LINE}
    ORG=${EMAIL}
    PASSWD=password # keep it simple
    SPACE=dev
    ROLE=SpaceDeveloper

    set -x; cf create-org ${EMAIL} | tee -a ${LOGFILE};                             { set +x; } 2>/dev/null
    set -x; cf create-space dev -o ${ORG} | tee -a ${LOGFILE};                      { set +x; } 2>/dev/null
    set -x; cf create-user ${EMAIL} ${PASSWD} | tee -a ${LOGFILE};                  { set +x; } 2>/dev/null
    set -x; cf set-space-role ${EMAIL} ${ORG} ${SPACE} ${ROLE} | tee -a ${LOGFILE}; { set +x; } 2>/dev/null

  done < "${1:-/dev/stdin}" # process next line of $1 or STDIN

  # shift to next arg (if any), and break id we're at zero args
  shift
  if [ $# -eq 0 ]; then
    break
  fi

done

printline "Operation complete"
