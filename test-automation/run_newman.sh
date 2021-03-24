#!/bin/bash


COLLECTION_ID=$(curl --location --request GET "https://api.getpostman.com/collections?apikey=${POSTMAN_API_KEY}" | \
jq --arg COLLECTION_NAME "$COLLECTION_NAME" '.collections[] | select(.name==$COLLECTION_NAME) | .uid')

COLLECTION_ID=${COLLECTION_ID%\"}
COLLECTION_ID="${COLLECTION_ID#\"}"

curl --location --request GET "https://api.getpostman.com/collections/$COLLECTION_ID?apikey=${POSTMAN_API_KEY}" \
>> collection.json


#report newman results to Testrail by chunks (newman run tests on folders and update the existing test runs)

while read line; do

  FOLDER=$(echo $line | sed 's/[0-9]*,//')
  export TESTRAIL_RUNID=$(echo $line | sed 's/,.*//')

  echo "start processing ${FOLDER}"

  newman run collection.json \
  --folder "$FOLDER" -e postman_environment_variables.json \
  --reporters cli,testrail \
  --timeout-request 30000 \
  --timeout-script 30000

  echo "processing ${FOLDER} finished"

done <postman_folders.txt
