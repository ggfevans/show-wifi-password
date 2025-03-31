#!/usr/bin/env bash

# Show WiFi Password - A simple CLI tool to retrieve WiFi passwords from macOS Keychain
# Usage: ./show-wifi.sh [options] [SSID]

set -e

# Colors for output
GREEN="\033[32m"
CYAN="\033[96m"
YELLOW="\033[33m"
RED="\033[31m"
GRAY="\033[90m"
RESET="\033[39m"

# Function to display usage information
show_help() {
  echo "Usage: $(basename "$0") [options] [SSID]"
  echo
  echo "Options:"
  echo "  -h, --help     Show this help message"
  echo "  -c, --copy     Copy password to clipboard instead of displaying it"
  echo "  -l, --list     List all saved WiFi networks"
  echo
  echo "If no SSID is provided, the currently connected network will be used."
}

# Function to get current SSID
get_current_ssid() {
  local ssid
  ssid=$(ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}')
  
  if [[ -z "$ssid" ]]; then
    # Try alternative interfaces in case en0 is not the active one
    for interface in en1 en2; do
      ssid=$(ipconfig getsummary "$interface" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')
      [[ -n "$ssid" ]] && break
    done
  fi
  
  echo "$ssid"
}

# Function to get password for a given SSID
get_password() {
  local ssid="$1"
  local sec_output
  
  echo -e "${GRAY}Getting password for \"${ssid}\"...${RESET}"
  echo -e "${GRAY}Keychain prompt incoming...${RESET}"
  
  sec_output=$(security find-generic-password -ga "${ssid}" 2>&1 >/dev/null)
  
  if [[ $? -eq 128 ]]; then
    echo -e "${YELLOW}User cancelled the operation.${RESET}"
    return 1
  fi
  
  local password
  password=$(sed -En 's/^password: "(.*)"$/\1/p' <<<"$sec_output")
  
  if [[ -z "$password" ]]; then
    echo -e "${RED}Password for \"${ssid}\" not found in Keychain.${RESET}" >&2
    return 1
  fi
  
  echo "$password"
}

# Function to list all saved WiFi networks
list_networks() {
  echo -e "${GRAY}Retrieving saved WiFi networks...${RESET}"
  security find-generic-password -D "AirPort network password" -a "AirPort" -g 2>&1 | \
    grep "\"ssid\"" | sed -E 's/.*"([^"]+)".*/\1/' | sort | uniq | \
    while read -r ssid; do
      echo -e "${GREEN}• ${ssid}${RESET}"
    done
}

# Default values
COPY_TO_CLIPBOARD=false
SHOW_LIST=false
SSID=""

# Parse command line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -c|--copy)
      COPY_TO_CLIPBOARD=true
      shift
      ;;
    -l|--list)
      SHOW_LIST=true
      shift
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      show_help
      exit 1
      ;;
    *)
      SSID="$1"
      shift
      ;;
  esac
done

# List networks if requested
if [[ "$SHOW_LIST" == true ]]; then
  list_networks
  exit 0
fi

# Get SSID if not provided
if [[ -z "$SSID" ]]; then
  SSID=$(get_current_ssid)
  if [[ -z "$SSID" ]]; then
    echo -e "${RED}Error retrieving current SSID. Are you connected to WiFi?${RESET}" >&2
    exit 1
  fi
fi

# Get password
PASSWORD=$(get_password "$SSID")
if [[ $? -ne 0 ]]; then
  exit 1
fi

# Output or copy the password
if [[ "$COPY_TO_CLIPBOARD" == true ]]; then
  echo -n "$PASSWORD" | pbcopy
  echo -e "${CYAN}✓ Password for \"${SSID}\" copied to clipboard${RESET}"
else
  echo -e "${CYAN}✓ Password for \"${SSID}\" is ${PASSWORD}${RESET}"
fi
