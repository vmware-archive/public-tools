#!/bin/bash

# delete the apps (recursive to kill service bindings)
for APPS_URL in $(cf curl /v2/spaces?q=name:dev | jq --raw-output .resources[].entity.apps_url); 
do
  for APP_URL in $(cf curl ${APPS_URL} | jq --raw-output .resources[].metadata.url);
  do
  	cf curl -X DELETE "${APP_URL}?async=true&recursive=true"
  done
done

#delete the services (recursive to kill the service keys)
for SERVICES_URL in $(cf curl /v2/spaces?q=name:dev | jq --raw-output .resources[].entity.service_instances_url); 
do
  for SERVICE_URL in $(cf curl ${SERVICES_URL} | jq --raw-output .resources[].metadata.url);
  do
   #  for SERVICE_KEY_URL in $(cf curl ${SERVICE_URL}/service_keys | jq --raw-output .resources[].metadata.url);
   #  do
   #    cf curl -X DELETE "${SERVICE_KEY_URL}?async=true"
   #  done
  	cf curl -X DELETE "${SERVICE_URL}?accepts_incomplete=true&async=true&recursive=true"
  done
done
