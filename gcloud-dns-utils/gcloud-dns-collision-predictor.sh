#!/bin/bash

PROJECT_NAME_SEARCH=CSO-Education-cls*

gcloud projects list --filter name:${PROJECT_NAME_SEARCH} --format='value[separator=" "](PROJECT_ID,NAME)' | \
while read -r LINE; do
  set ${LINE}
  PROJECT_ID=${1}
  PROJECT_NAME=${2}
  SUBDOMAIN_NAME=$(echo ${PROJECT_NAME} | cut -d '-' -f3)
  OPS_MANAGER_FQDN=pcf.${SUBDOMAIN_NAME}.pivotaledu.io
  OPS_MANAGER_IP_ADDRESS=$(dig +short ${OPS_MANAGER_FQDN})
  if [[ ${OPS_MANAGER_IP_ADDRESS} ]]; then
    echo "${PROJECT_NAME} (${PROJECT_ID}) - ${OPS_MANAGER_FQDN} resolves to ${OPS_MANAGER_IP_ADDRESS}"
  else
    echo "${PROJECT_NAME} (${PROJECT_ID}) - ${OPS_MANAGER_FQDN} not resolved"
  fi
done