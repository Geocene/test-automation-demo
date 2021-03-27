#!/bin/bash


COLLECTION_ID=$(curl --location --request GET "https://api.getpostman.com/collections?apikey=${POSTMAN_API_KEY}" | \
jq --arg COLLECTION_NAME "$COLLECTION_NAME" '.collections[] | select(.name==$COLLECTION_NAME) | .uid')

ENVIRONMENT_ID=$(curl --location --request GET "https://api.getpostman.com/environments?apikey=${POSTMAN_API_KEY}" | \
jq --arg ENVIRONMENT_NAME "$ENVIRONMENT_NAME" '.environments[] | select(.name==$ENVIRONMENT_NAME) | .uid')

COLLECTION_ID=${COLLECTION_ID%\"}
COLLECTION_ID="${COLLECTION_ID#\"}"
ENVIRONMENT_ID=${ENVIRONMENT_ID%\"}
ENVIRONMENT_ID="${ENVIRONMENT_ID#\"}"

curl --location --request GET "https://api.getpostman.com/collections/$COLLECTION_ID?apikey=${POSTMAN_API_KEY}" \
>> collection.json

curl --location --request GET "https://api.getpostman.com/environments/$ENVIRONMENT_ID?apikey=${POSTMAN_API_KEY}" \
>> postman_environment_variables.json

#report newman results to Testrail by chunks (newman run tests on folders and update the existing test runs)

curl -H "Content-Type: application/json" -u "${TEST_RAIL_USERNAME}:${TEST_RAIL_PASSWORD}" \
 "https://arabletestrail.testrail.io/index.php?/api/v2/get_runs/${TEST_RAIL_PROJECT_ID}" >> test_runs.json

jq -c '.[]' test_runs.json | while read i; do

  TEST_RUN_NAME=$(echo $i | jq '.name')
  TEST_RUN_ID=$(echo $i | jq '.id')

  echo "start processing ${TEST_RUN_NAME}"

  newman run collection.json \
  --folder "$TEST_RUN_NAME" -e postman_environment_variables.json \
  --reporters cli,testrail \
  --timeout-request 30000 \
  --timeout-script 30000

  echo "processing ${TEST_RUN_NAME} finished"


done