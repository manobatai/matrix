#!/usr/bin/env bash

set -ueo pipefail

URLS=( \
  http://downloads.asterisk.org/pub/telephony/asterisk/releases/ \
  http://downloads.asterisk.org/pub/telephony/asterisk/ \
  http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/ \
  http://downloads.asterisk.org/pub/telephony/certified-asterisk/ \
  http://downloads.asterisk.org/pub/telephony/certified-asterisk/releases/ \
)

# URLS=( \
#   http://downloads.asterisk.org/pub/telephony/asterisk/releases/ \
# )

ASTERISK_VERSIONS=""
for URL in "${URLS[@]}"; do
  _ASTERISK_VERSIONS="$( \
    curl -sL "${URL}" \
    | grep '<a href="asterisk.*.tar.gz">' \
    | grep -v '\-patch\|\-addons\|\-sounds' \
    | awk -F '</td><td>|">asterisk' '{print $2}' \
    | awk -F '"' '{print $NF}' \
    | awk -F '.tar.gz' '{print $1}' \
  )"
  ASTERISK_VERSIONS="$(echo -e "\n${ASTERISK_VERSIONS}\n${_ASTERISK_VERSIONS}")"
done

ASTERISK_VERSIONS="$(echo -e "${ASTERISK_VERSIONS}" | sort -u | xargs)"

# # convert space-delimited string to the array
# read -ra ASTERISK_VERSIONS <<< "${ASTERISK_VERSIONS}"

# echo "Asterisk versions:"
# echo "------------------"
# # echo "${ASTERISK_VERSIONS[@]}"
# for ASTERISK_VERSION in "${ASTERISK_VERSIONS[@]}"; do
#   echo "v ${ASTERISK_VERSION}"
# done

# "{\"include\":[{\"run\":\"run1\"},{\"run\":\"run2\"}]}"
# echo -n "1 2 3" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'
echo -n "${ASTERISK_VERSIONS}" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'

