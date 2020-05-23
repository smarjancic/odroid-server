#!/usr/bin/with-contenv bash

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