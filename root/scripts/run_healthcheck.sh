#!/usr/bin/with-contenv bash

declare -A hashmap

while IFS="=" read -r key value
do
    hashmap[$key]="$value"
done < <(jq -r 'to_entries|map("(.key)=(.value)")|.[]' /config/healthcheck.json)

# Pi Hole
hashmap["0626ec70-1a2b-4e93-8f26-444b6b70f521"]="http://192.168.90.220:80"

for key in "${!hashmap[@]}"; do /scripts/_healthcheck.sh $key "${hashmap[$key]}"; done