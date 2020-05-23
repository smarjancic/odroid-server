#!/usr/bin/with-contenv bash

declare -A hashmap

# Pi Hole
hashmap["0626ec70-1a2b-4e93-8f26-444b6b70f521"]="http://192.168.90.220:80"

for key in "${!hashmap[@]}"; do /scripts/health_check.sh $key "${hashmap[$key]}"; done