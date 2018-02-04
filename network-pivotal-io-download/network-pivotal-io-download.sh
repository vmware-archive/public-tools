#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------------
# Get your API_TOKEN from https://network.pivotal.io/users/dashboard/edit-profile and pass in on command line to this script, for example:
#
# API_TOKEN=DctsxNhqDc4RLqxZExYx ./network-pivotal-io-download.sh student-files.txt
# --------------------------------------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------------------------------------
# The script expects an input text file (e.g. student-files.txt) or stdin lines formatted as space-delimited triplets of [PRODUCT_SLUG] [PRODUCT_VERSION] [RELEASE_ID]

# where these values are obtained by selecting the (i) INFO icon for the associated Pivotal Network download, for example:
#
# ops-manager     1.12.5 35440
# elastic-runtime 1.12.8 36393
# ... and so on
# --------------------------------------------------------------------------------------------------------------------------------------------------

set -u # explode if any env vars are not set (e.g. API_TOKEN)
echo ${API_TOKEN} > /dev/null

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

# for platform independence
REALPATH="realpath"
if ! which ${REALPATH} > /dev/null ; then
  REALPATH="readlink -f"
fi

SCRIPTDIR=$(dirname $(${REALPATH} $0))

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

    PRODUCT_SLUG=$(echo ${LINE} | cut -d " " -f1)
    PRODUCT_VERSION=$(echo ${LINE} | cut -d " " -f2)
    RELEASE_ID=$(echo ${LINE} | cut -d " " -f3)

    printline "Downloading ${PRODUCT_SLUG} ${PRODUCT_VERSION} ${RELEASE_ID}"
    DOWNLOADS=${SCRIPTDIR}/downloads
    if [ ! -d ${DOWNLOADS} ]; then
      mkdir ${DOWNLOADS}
    fi

    pushd ${DOWNLOADS} > /dev/null
    if ${SCRIPTDIR}/pivnet-linux login --api-token=${API_TOKEN}; then
      if ${SCRIPTDIR}/pivnet-linux accept-eula -p ${PRODUCT_SLUG} -r ${PRODUCT_VERSION}; then
        ${SCRIPTDIR}/pivnet-linux download-product-files -p ${PRODUCT_SLUG} -r ${PRODUCT_VERSION} -i ${RELEASE_ID}
      fi
    fi
    popd > /dev/null

    # only attempt to import to PCF if OPSMAN_USER was provided
    if [ -z ${OPSMAN_USER+x} ]; then
      continue 
    fi

    # just cycle contents of downloads directory
    # because we don't know the name of the file we just got
    for FILE_NAME in $(ls ${DOWNLOADS}); do

      OM_CMD="upload-product -p"
      if echo ${FILE_NAME} | grep -q "stemcell"; then
        OM_CMD="upload-stemcell -f -s"
      fi

      printline "Importing: ${OM_CMD} ${FILE_NAME}"
      ${SCRIPTDIR}/om-linux -k -t ${OPSMAN_URL} -u ${OPSMAN_USER} -p $OPSMAN_PASSWD ${OM_CMD} ${DOWNLOADS}/${FILE_NAME}

      IMPORTED=${SCRIPTDIR}/imported
      if [ ! -d ${IMPORTED} ]; then
        mkdir ${IMPORTED}
      fi

      # zero-byte and archive file
      echo > ${DOWNLOADS}/${FILE_NAME} && mv ${DOWNLOADS}/${FILE_NAME} ${IMPORTED}

      printline "Imported: ${OM_CMD} ${FILE_NAME}"

    done # process nest FILE_NAME

  done < "${1:-/dev/stdin}" # process next line of $1 or STDIN

  # shift to next arg (if any), and break id we're at zero args
  shift
  if [ $# -eq 0 ]; then
    break
  fi

done

printline "Operation complete"
