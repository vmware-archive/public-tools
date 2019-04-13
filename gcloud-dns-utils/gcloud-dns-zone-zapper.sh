#!/bin/bash

PROJECT_NAME_SEARCH=CSO-Education-cls*
echo "# execute the following commands to remove all Cloud DNS entries from ${PROJECT_NAME_SEARCH}"
gcloud projects list --filter name:${PROJECT_NAME_SEARCH} --format='value[separator=" "](PROJECT_ID,NAME)' | \
while read -r LINE; do
  set ${LINE}
  PROJECT_ID=${1}
  PROJECT_NAME=${2}
  if [[ $(gcloud services list --project ${PROJECT_ID} --filter name:dns.googleapis.com --format='value(NAME)') ]]; then
    gcloud dns managed-zones list --project ${PROJECT_ID} --format='value(name)' | \
    while read -r LINE; do
      set ${LINE}
      ZONE=${1}
      echo "gcloud dns record-sets import --project ${PROJECT_ID} --zone ${ZONE} --delete-all-existing /dev/null"
      echo "gcloud dns managed-zones delete --project ${PROJECT_ID} ${ZONE}"
    done
  fi
done