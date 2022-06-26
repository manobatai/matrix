#!/usr/bin/env bash

readarray -t ASTERISK_RELEASES < ./releases-dev.txt

echo "Asterisk releases:"
echo "------------------"
# echo "${ASTERISK_RELEASES[@]}"
for ASTERISK_RELEASE in "${ASTERISK_RELEASES[@]}"; do
  echo "v ${ASTERISK_RELEASE}"
done


set -ueox pipefail

max() {
  declare -a ARRAY=("${!1}")
  local MAX=0
  for VAL in "${ARRAY[@]}"; do
    if (( VAL > MAX )); then
      MAX=$VAL
    fi
  done
  unset ARRAY
  echo -n "$MAX"
}

# https://stackoverflow.com/questions/14928573/sed-how-to-extract-ip-address-using-sed
RELEASES=("10" "30" "44" "44" "69" "12" "11" "100" "105")
data="$(max RELEASES[@])"
echo "max: $data"
