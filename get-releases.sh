#!/usr/bin/env bash

set -ueo pipefail

fetch() {
  declare -a URLS=("${!1}")
  local ASTERISK_RELEASES=""

  for URL in "${URLS[@]}"; do
    _ASTERISK_RELEASES="$( \
      curl \
        --silent \
        --location \
        --connect-timeout 5 \
        --max-time 10 \
        --retry 5 \
        --retry-delay 0 \
        --retry-max-time 40 \
        "${URL}" \
      | grep '<a href="asterisk.*.tar.gz">' \
      | grep -v '\-patch\|\-addons\|\-sounds' \
      | awk -F '</td><td>|">asterisk' '{print $2}' \
      | awk -F '"' '{print $NF}' \
      | awk -F 'asterisk-certified-' '{print $NF}' \
      | awk -F 'asterisk-' '{print $NF}' \
      | awk -F '.tar.gz' '{print $1}' \
    )"
    ASTERISK_RELEASES="$(echo -en "${ASTERISK_RELEASES}\n${_ASTERISK_RELEASES}")"
  done

  ASTERISK_RELEASES="$( \
    echo -en "${ASTERISK_RELEASES}" | sort --unique \
    | sort --field-separator='.' --key=1,1n  --key=2,2n --key=3,3n --key=4,4n \
  )"

  unset URLS
  echo -en "$ASTERISK_RELEASES"
}

URLS=( \
  http://downloads.asterisk.org/pub/telephony/asterisk/releases/ \
  http://downloads.asterisk.org/pub/telephony/asterisk/ \
  http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/ \
)

# ASTERISK_RELEASES="$(fetch URLS[@])"
# echo -e "$ASTERISK_RELEASES" > asterisk-releases.txt



ASTERISK_RELEASES="$( \
  sort --unique ./asterisk-releases.txt \
  | sort --field-separator='.' --key=1,1n  --key=2,2n --key=3,3n --key=4,4n \
)"

ALPHA_RELEASES="$(echo "$ASTERISK_RELEASES" | grep -P '\-alpha\d+$')"

BETA_RELEASES="$(echo "$ASTERISK_RELEASES" | grep -P '\-beta\d+$')"

RC_RELEASES="$(echo "$ASTERISK_RELEASES" | grep -P '\-rc\d+$')"

CURRENT_RELEASES="$(echo "$ASTERISK_RELEASES" | grep -P '\-current$')"

STABLE_RELEASES="$(echo "$ASTERISK_RELEASES" | grep -P '\d+\.\d+\.\d+(|\.\d+(|\.\d+))$')"

BUILD_RELEASES="$(
  set +e
  for MAJOR_RELEASE in '1.2' '1.4' '1.6' '1.8' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19'
  do
    STABLE_RELEASE="$(echo "$STABLE_RELEASES" | grep "^$MAJOR_RELEASE\." | tail -n1)"
    echo "$STABLE_RELEASE"
    echo "$CURRENT_RELEASES" | grep "^$MAJOR_RELEASE-" | tail -n1
    RECENT_TEST_RELEASE="$(
      (
        echo "$STABLE_RELEASES" | grep "^$MAJOR_RELEASE\." | tail -n1
        echo "$ALPHA_RELEASES" | grep "^$MAJOR_RELEASE\." | tail -n1
        echo "$BETA_RELEASES" | grep "^$MAJOR_RELEASE\." | tail -n1
        echo "$RC_RELEASES" | grep "^$MAJOR_RELEASE\." | tail -n1
      ) \
      | sort --field-separator='.' --key=1,1n  --key=2,2n --key=3,3n --key=4,4n \
      | tail -n1
    )"
    echo "$RECENT_TEST_RELEASE" | grep "$STABLE_RELEASE" > /dev/null || echo "$RECENT_TEST_RELEASE"
  done
  set -e
)"

echo -e "$BUILD_RELEASES"
JSON_MATRIX="$(
  echo -n "$BUILD_RELEASES" \
  | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'
)"

echo -e $JSON_MATRIX

# URLS=( \
#   http://downloads.asterisk.org/pub/telephony/certified-asterisk/ \
#   http://downloads.asterisk.org/pub/telephony/certified-asterisk/releases/ \
# )

# ASTERISK_RELEASES="$(fetch URLS[@])"

# echo -e "$ASTERISK_RELEASES" > asterisk-certified-releases.txt

# STABLE_RELEASES=1
# BETA_RELEASES=1
# RC_RELEASES=1
# CURRENT_RELEASES=1



# echo "${ASTERISK_RELEASES}"
# # convert space-delimited string to the array
# read -ra ASTERISK_RELEASES <<< "${ASTERISK_RELEASES}"
# echo "${ASTERISK_RELEASES[@]}"

# echo "Asterisk releases:"
# echo "------------------"
# # echo "${ASTERISK_RELEASES[@]}"
# for ASTERISK_RELEASE in "${ASTERISK_RELEASES[@]}"; do
#   echo "v ${ASTERISK_RELEASE}"
# done

# "{\"include\":[{\"run\":\"run1\"},{\"run\":\"run2\"}]}"
# echo -n "1 2 3" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'
# echo -n "${ASTERISK_RELEASES}" | jq --slurp -c -R 'split(" ") | map({run: .}) | {include: .}'

