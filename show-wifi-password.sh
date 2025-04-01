#!/usr/bin/env bash

# Show WiFi Password - A simple CLI tool to retrieve WiFi passwords from macOS Keychain
# Usage: ./show-wifi-password.sh [options] [SSID]

VERSION="0.1.0"

set -e

# Function to display version information
show_version() {
  echo "Show WiFi Password v${VERSION}"
  echo "A simple macOS CLI tool to retrieve WiFi passwords from your Keychain."
  echo "Copyright (c) 2025 Gareth Evans"
  echo "Licensed under MIT License"
}

# Check if the script is running on macOS, if not bail out
check_platform() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "Error: This script only works on macOS systems.${RESET}" >&2
    echo -e "This tool relies on macOS-specific commands to access the Keychain.${RESET}" >&2
    exit 2
  fi
}
check_platform

# Colours for output
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
  echo "  -v, --version  Show version information"
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
  
  # Send informational messages to stderr so they don't get captured
  echo -e "${GRAY}Getting password for \"${ssid}\"...${RESET}" >&2
  echo -e "${GRAY}Keychain prompt incoming...${RESET}" >&2
  
  sec_output=$(security find-generic-password -ga "${ssid}" 2>&1 >/dev/null)
  
  if [[ $? -eq 128 ]]; then
    echo -e "${YELLOW}User cancelled the operation.${RESET}" >&2
    return 1
  fi
  
  local password
  password=$(sed -En 's/^password: "(.*)"$/\1/p' <<<"$sec_output")
  
  if [[ -z "$password" ]]; then
    echo -e "${RED}Password for \"${ssid}\" not found in Keychain.${RESET}" >&2
    return 1
  fi
  
  # Return only the password
  echo "$password"
}

# Default values
COPY_TO_CLIPBOARD=false
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
    -v|--version)
      show_version
      exit 0
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
