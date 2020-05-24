#!/usr/bin/with-contenv bash

get_torrentleech() {
  cd /config/temp

  username=$(jq .torrentleech.username /config/torrents.json)
  password=$(jq .torrentleech.password /config/torrents.json)
  userID=$(jq .torrentleech.userID /config/torrents.json)
  seedTime=$(jq -r .torrentleech.seedTime /config/torrents.json)
  cookieUrl=$(jq -r .torrentleech.cookieUrl /config/torrents.json)
  seedUrl=$(jq -r .torrentleech.seedUrl /config/torrents.json)

  wget --load-cookies tlcookie.txt --keep-session-cookies --save-cookies tlcookie.txt --post-data "$cookieUrl" $seedUrl

  torrents=$(cat snatchlist | grep '{"sEcho": 1,' | sed 's|<[^>]*>||g' | jq -r --arg seedTime "$seedTime" '(.aaData | map(select(.[8]=="Yes") | select(.[9]|startswith($seedTime)) | .[0]))')
  if [[ $torrents -ne 0]]; then
    printf "%s" "$torrents" > /config/temp/tlresult.json
  else
    jq -n '[]' > /config/temp/tlresult.json
  fi
}

get_iptorrents() {
  cd /config/temp
  
  cookie=$(jq -r .iptorrents.cookie /config/torrents.json)
  seedUrl=$(jq -r .iptorrents.seedUrl /config/torrents.json)
  
  curl --header "$cookie" --request GET $seedUrl > iptsnatchlist
  
  parsedData=$(sed 's/.*Seeders//;s/<tr><td colspan=99 class=ac>Leechers.*//' iptsnatchlist)
  parsedData=$(sed -e 's/<td class=ar>/<td>/g' -e $'s/<tr>/\\\n/g' <<< $parsedData)
  parsedData=$(sed -e 's/<td>/|/g' <<< $parsedData)
  parsedData=$(grep -v "^$" <<< $parsedData)
  
  declare -a array_torrent
  
  while IFS='|' read -r empty torrent user percent uploaded uprate downloaded downrate seedingtime client adress; do
    if [[ $seedingtime == 0.0* ]] ;
    then
        torrentName=$(sed -e 's/.*">//;s/<\/a>.*//' <<< $torrent)
        array_torrent+=("$torrentName")
    fi
  done <<< $parsedData
  
  if [ ${#array_torrent[@]} -eq 0 ]; then
    jq -n '[]' > /config/temp/iptresult.json
  else
    printf '%s\n' "${array_torrent[@]}" | jq -R . | jq -s . > /config/temp/iptresult.json
  fi
}

get_result() {
  cd /config/temp

  action=$(jq -r .ifttt.action /config/torrents.json)
  key=$(jq -r .ifttt.key /config/torrents.json)

  completedSeeding=$(jq -r -s '.[0]+.[1]-.[2]' /config/temp/tlresult.json /config/temp/iptresult.json /config/temp/results.json)

  totalCompletedSeeding=$(jq 'length' <<< "$completedSeeding")

  if  [ $totalCompletedSeeding -ne 0 ]
  then
      completedSeeding=$(jq -r '@csv' <<< "$completedSeeding")
      completedSeeding=$(sed 's/\s*","/,/g' <<< "$completedSeeding")
      curl --header "Content-Type: application/json" --data "$(generate_data)" https://maker.ifttt.com/trigger/$action/with/key/$key
  fi

  (jq -r -s '.[0]+.[1]' /config/temp/tlresult.json /config/temp/iptresult.json) > /config/temp/results.json
}

generate_data()
{
  cat <<EOF
{
  "value1": $completedSeeding
}
EOF
}

do_cleanup() {
  cd /config/temp

  find . -name '*snatchlist*' -exec rm -f {} \;
}

get_torrentleech
get_iptorrents
get_result
do_cleanup
