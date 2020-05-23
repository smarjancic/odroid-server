#!/usr/bin/with-contenv bash

status_code=$(curl -Ls -o /dev/null -i -w "%{http_code}" $2)
if [[ "$status_code" -ne 200 ]] ; then
  curl -s --retry 3 https://hc-ping.com/$1/fail > /dev/null
else
  curl -s --retry 3 https://hc-ping.com/$1 > /dev/null
fi