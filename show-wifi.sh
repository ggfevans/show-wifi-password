#!/usr/bin/env bash

if [[ -n $1 ]]; then
   SSID=$1
else
   # WIFI_IF=$(iscutil <<< "list" | grep -m1 'AirPort' | awk -F/ '{print $(NF-1)}')
   SSID=$(ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}')
   [[ -n $SSID ]] || { echo 1>&2 "error retrieving current SSID. are you connected?"; exit 1; }
fi
echo -e "\033[90m … getting password for \"${SSID}\". \033[39m"
echo -e "\033[90m … keychain prompt incoming. \033[39m"
SECOUT=$(security find-generic-password -ga "${SSID}" 2>&1 >/dev/null)
(( $? == 128 )) && { echo "user cancelled"; exit 0; }
PASS=$(sed -En 's/^password: "(.*)"$/\1/p' <<<"$SECOUT")
[[ -n $PASS ]] || { echo 1>&2 "password for \"${SSID}\" not found in Keychain"; exit 1; }
echo -e "\033[96m ✓ ${PASS} \033[39m"
