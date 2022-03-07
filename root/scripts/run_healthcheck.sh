#!/bin/bash

do_healthcheck() {
  if  [[ $2 = http* ]] ; then
    status_code=$(curl -Ls -o /dev/null -i -w "%{http_code}" $2)
  else
    if  ping -q -c 1 $2 2>&1 >/dev/null ; then
      status_code=200
    fi
  fi
  if [[ "$status_code" -ne 200 ]] ; then
    curl -s --retry 3 https://hc-ping.com/$1/fail > /dev/null
  else
    curl -s --retry 3 https://hc-ping.com/$1 > /dev/null
  fi
}

declare -A hashmap

while IFS="=" read -r key value
do
    hashmap[$key]="$value"
done < <(jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' /config/healthcheck.json)

for key in "${!hashmap[@]}"; do do_healthcheck $key "${hashmap[$key]}"; done