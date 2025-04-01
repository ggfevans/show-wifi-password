#!/usr/bin/env bash
#
# show-wifi-password.sh - Retrieve WiFi passwords from macOS Keychain
#
# A simple CLI tool to access WiFi passwords stored in the macOS Keychain
# without navigating through System Preferences.
#
# Usage: ./show-wifi-password.sh [options] [SSID]
#
# Author: Gareth Evans
# Version: 1.0.0
# License: MIT

# Exit on error
set -e

# Display version information
show_version() {
  echo "Show WiFi Password v${VERSION}"
  echo "A simple macOS CLI tool to retrieve WiFi passwords from your Keychain."
  echo "Copyright (c) 2025 Gareth Evans"
  echo "Licensed under MIT License"
}

# Verify the script is running on macOS
check_platform() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "Error: This script only works on macOS systems.${RESET}" >&2
    echo -e "This tool relies on macOS-specific commands to access the Keychain.${RESET}" >&2
    exit 2
  fi
}

# Terminal color definitions
GREEN="\033[32m"
CYAN="\033[96m"
YELLOW="\033[33m"
RED="\033[31m"
GRAY="\033[90m"
RESET="\033[39m"

# Display usage information and command options
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

# Detect the currently connected WiFi network name
get_current_ssid() {
  local ssid
  ssid=$(ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}')
  
  # Try other interfaces if en0 is not connected
  if [[ -z "$ssid" ]]; then
    for interface in en1 en2; do
      ssid=$(ipconfig getsummary "$interface" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')
      [[ -n "$ssid" ]] && break
    done
  fi
  
  echo "$ssid"
}

# Verify the SSID meets WiFi specification requirements
validate_ssid() {
  local ssid="$1"
  
  # IEEE 802.11 standard requires non-empty SSIDs
  if [[ -z "$ssid" ]]; then
    echo -e "${RED}Error: Empty SSID provided.${RESET}" >&2
    return 1
  fi
  
  # IEEE 802.11 standard allows maximum 32 bytes for SSID
  if [[ "${#ssid}" -gt 32 ]]; then
    echo -e "${RED}Error: SSID exceeds maximum length of 32 characters.${RESET}" >&2
    return 1
  fi
  
  return 0
}

# Retrieve the password for a WiFi network from the Keychain
get_password() {
  local ssid="$1"
  local sec_output
  
  validate_ssid "$ssid" || return 1
  
  # Status messages directed to stderr to avoid capturing in output
  echo -e "${GRAY}Getting password for \"${ssid}\"...${RESET}" >&2
  echo -e "${GRAY}Keychain prompt incoming...${RESET}" >&2
  
  # Query Keychain for the WiFi password
  sec_output=$(security find-generic-password -ga "${ssid}" 2>&1 >/dev/null)
  local sec_exit_code=$?
  
  # Handle various security command exit codes
  if [[ $sec_exit_code -eq 128 ]]; then
    echo -e "${YELLOW}User cancelled the operation.${RESET}" >&2
    return 1
  elif [[ $sec_exit_code -eq 44 ]]; then
    echo -e "${RED}Network \"${ssid}\" not found in Keychain.${RESET}" >&2
    return 1
  elif [[ $sec_exit_code -ne 0 ]]; then
    echo -e "${RED}Error accessing Keychain (code: ${sec_exit_code}).${RESET}" >&2
    return 1
  fi
  
  # Extract password from security command output
  local password
  password=$(echo "$sec_output" | grep -o 'password: "[^"]*"' | sed -E 's/^password: "(.*)"/\1/')
  
  if [[ -z "$password" ]]; then
    echo -e "${RED}Password for \"${ssid}\" not found or format unexpected.${RESET}" >&2
    return 1
  fi
  
  # Return only the password
  echo "$password"
}

#-------------------------------------------------------------------------------
# Main Script Execution
#-------------------------------------------------------------------------------

VERSION="0.1.0"

# Ensure we're running on macOS
check_platform

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

# Use current WiFi network if no SSID provided
if [[ -z "$SSID" ]]; then
  SSID=$(get_current_ssid)
  if [[ -z "$SSID" ]]; then
    echo -e "${RED}Error retrieving current SSID. Are you connected to WiFi?${RESET}" >&2
    exit 1
  fi
fi

# Get password for the specified network
PASSWORD=$(get_password "$SSID")
if [[ $? -ne 0 ]]; then
  exit 1
fi

# Output result based on user preference
if [[ "$COPY_TO_CLIPBOARD" == true ]]; then
  echo -n "$PASSWORD" | pbcopy
  echo -e "${CYAN}✓ Password for \"${SSID}\" copied to clipboard${RESET}"
else
  echo -e "${CYAN}✓ Password for \"${SSID}\" is ${PASSWORD}${RESET}"
fi
