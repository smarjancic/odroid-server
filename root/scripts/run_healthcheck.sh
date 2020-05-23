#!/usr/bin/with-contenv bash

declare -A hashmap

while IFS="=" read -r key value
do
    hashmap[$key]="$value"
done < <(jq -r 'to_entries|map("(.key)=(.value)")|.[]' /config/healthcheck.json)

for key in "${!hashmap[@]}"; do /scripts/_healthcheck.sh $key "${hashmap[$key]}"; done