# Show WiFi Password

A simple macOS CLI tool to quickly retrieve WiFi passwords from your Keychain.

## About

I created this tool out of curiosity to see if it was feasible to access stored WiFi passwords programmatically and as a practical exercise to improve my macOS shell scripting skills. The script leverages the macOS `security` command to safely access credentials stored in your Keychain.

## Installation

```bash
# Clone the repository
git clone https://github.com/ggfevans/show-wifi-password.git

# Make the script executable
cd show-wifi-password
chmod +x show-wifi-password.sh

# Optional: create a symlink for easier access
ln -s "$(pwd)/show-wifi-password.sh" /usr/local/bin/show-wifi-password
```

## Usage

# Show password for current WiFi network
./show-wifi-password.sh

# Show password for a specific network
./show-wifi-password.sh "My-Network-Name"

# Copy the current network's password to clipboard
./show-wifi-password.sh -c

# Display help
./show-wifi-password.sh -h

## Features

- Retrieves passwords from macOS Keychain securely
- Automatically detects current WiFi network
- Option to copy password to clipboard
- Works across different WiFi interfaces (en0, en1, en2)
- User-friendly terminal output with color coding

## Security

This tool uses the built-in `security` command to access your Keychain. When you run the script:

1. macOS will prompt for your permission to access the Keychain
2. No passwords are stored or transmitted anywhere
3. When using the clipboard option (-c), the password remains in your clipboard until overwritten

## Compatibility

Tested on:
- macOS Sonoma (14.x)
