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

# ASTERISK_VERSIONS="$(echo -e "${ASTERISK_VERSIONS}" | sort -u | xargs)"
ASTERISK_VERSIONS="$(echo -e "${ASTERISK_VERSIONS}" | sort -u)"
unset _ASTERISK_VERSIONS
# unset ASTERISK_VERSIONS

ASTERISK_0="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-0.1.")"
ASTERISK_1_0="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-1.0.")"
ASTERISK_1_2="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-1.2.")"
ASTERISK_1_4="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-1.4.")"
ASTERISK_1_6="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-1.6.")"
ASTERISK_1_8="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-1.8.")"
ASTERISK_10="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-10.")"
ASTERISK_11="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-11.")"
ASTERISK_12="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-12.")"
ASTERISK_13="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-13.")"
ASTERISK_14="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-14.")"
ASTERISK_15="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-15.")"
ASTERISK_16="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-16.")"
ASTERISK_17="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-17.")"
ASTERISK_18="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-18.")"
ASTERISK_19="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-19.")"
ASTERISK_CERT="$(echo "${ASTERISK_VERSIONS}" | grep "asterisk-certified-")"

echo -e "Asterisk PBX 0.x ("$(echo "${ASTERISK_0}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 1.0.x ("$(echo "${ASTERISK_1_0}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 1.2.x ("$(echo "${ASTERISK_1_2}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 1.4.x ("$(echo "${ASTERISK_1_4}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 1.6.x ("$(echo "${ASTERISK_1_6}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 1.8.x ("$(echo "${ASTERISK_1_8}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 10.x ("$(echo "${ASTERISK_10}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 11.x ("$(echo "${ASTERISK_11}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 12.x ("$(echo "${ASTERISK_12}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 13.x ("$(echo "${ASTERISK_13}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 14.x ("$(echo "${ASTERISK_14}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 15.x ("$(echo "${ASTERISK_15}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 16.x ("$(echo "${ASTERISK_16}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 17.x ("$(echo "${ASTERISK_17}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 18.x ("$(echo "${ASTERISK_18}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX 19.x ("$(echo "${ASTERISK_19}" | grep -c "asterisk-")" records)"
echo -e "Asterisk PBX (certified) "$(echo "${ASTERISK_CERT}" | grep -c "asterisk-")" records"

# echo "${ASTERISK_VERSIONS}"
# # convert space-delimited string to the array
# read -ra ASTERISK_VERSIONS <<< "${ASTERISK_VERSIONS}"
# echo "${ASTERISK_VERSIONS[@]}"

# echo "Asterisk versions:"
# echo "------------------"
# # echo "${ASTERISK_VERSIONS[@]}"
# for ASTERISK_VERSION in "${ASTERISK_VERSIONS[@]}"; do
#   echo "v ${ASTERISK_VERSION}"
# done

# "{\"include\":[{\"run\":\"run1\"},{\"run\":\"run2\"}]}"
# echo -n "1 2 3" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'
# echo -n "${ASTERISK_VERSIONS}" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'

