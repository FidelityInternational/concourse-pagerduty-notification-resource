#!/bin/bash
set -ue

# for jq
PATH=/usr/local/bin:$PATH

if [ "${SMUGGLER_pd_service_key}" = "" ]; then
  echo 'pd_service_key must be set on source'
  exit 1
fi
if [ "${SMUGGLER_description}" = "" ]; then
  echo 'description must be set on params'
  exit 1
fi

SMUGGLER_atc_external_url=${SMUGGLER_atc_external_url:-${ATC_EXTERNAL_URL}}
error_context="No error context possible without valid ATC url and credentials."
if [ "${SMUGGLER_atc_external_url:-}" != "" ] && [ "${SMUGGLER_atc_username:-}" != "" ] && [ "${SMUGGLER_atc_password:-}" != "" ]; then
    error_context="$(python /opt/resource/pd_error_capture.py \
    ${SMUGGLER_atc_external_url} \
    ${SMUGGLER_atc_username} \
    ${SMUGGLER_atc_password} \
    ${BUILD_ID})"
fi

concourse_build_url="${SMUGGLER_atc_external_url}/builds/${BUILD_ID}"

data="$(
jq -n \
  --arg description "${SMUGGLER_description}" \
  --arg service_key "${SMUGGLER_pd_service_key}" \
  --arg incident_key "${BUILD_PIPELINE_NAME}/${BUILD_JOB_NAME}" \
  --arg output "${error_context}" \
  --arg concourse_build_url "${concourse_build_url}" \
  --arg pipeline_name "${BUILD_PIPELINE_NAME}" \
  --arg job_name "${BUILD_JOB_NAME}" \
  '
    {
      "event_type": "trigger",
      "service_key": $service_key,
      "description": $description,
      "incident_key": $concourse_build_url,
      "client": "concourse",
      "client_url": $concourse_build_url,
      "details": {
        "pipeline": $pipeline_name,
        "job_name": $job_name,
        "concourse_build_url": $concourse_build_url,
        "output": $output
      },
      "contexts": []
    }
'
)"

response=$(curl -s \
  -H 'Accept: */*' \
  -H 'Content-Type: application/json' \
  -X POST \
  --data-binary "$data" \
  "https://events.pagerduty.com/generic/2010-04-15/create_event.json")

status=$(echo "$response" | jq -r '.status // ""')
incident_key=$(echo "$response" | jq -r '.incident_key // ""')
if [ "$status" != "success" ]; then
  echo "Alerting to pagerduty failed"
  echo $response
  exit 1
fi

echo "{\"version\": {\"ref\": \"${SMUGGLER_pd_service_key}\"},\"metadata\":[${response}]}"
