#!/bin/bash

status_code=$(curl -s -o /dev/null -i -w "%{http_code}" $2)
if [[ "$status_code" -ne 200 ]] ; then
  curl --retry 3 https://hc-ping.com/$1 > /dev/null
else
  exit 0
fi