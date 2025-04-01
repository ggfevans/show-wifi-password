# Show WiFi Password

[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](https://github.com/ggfevans/show-wifi-password)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Shell: Bash](https://img.shields.io/badge/shell-bash-89e051.svg)](https://github.com/ggfevans/show-wifi-password)

A lightweight macOS command-line utility to easily retrieve WiFi passwords from your Keychain.

## Overview

This tool provides a simple way to access stored WiFi passwords through macOS Keychain, eliminating the need to navigate through System Preferences. It was developed as a practical exercise in macOS shell scripting and to streamline access to saved network credentials.

## Features

- 🔑 Securely retrieves passwords from macOS Keychain
- 🔄 Automatically detects and displays the current WiFi network password
- 📋 Option to copy password directly to clipboard
- 🎨 User-friendly terminal output with colour-coded messages

## Installation

```bash
# Clone the repository
git clone https://github.com/ggfevans/show-wifi-password.git

# Change to project directory
cd show-wifi-password

# Make the script executable
chmod +x show-wifi-password.sh

# Optional: create a symlink for system-wide access
ln -s "$(pwd)/show-wifi-password.sh" /usr/local/bin/show-wifi-password
```

## Usage

```bash
# Show password for current WiFi network
./show-wifi-password.sh

# Show password for a specific network
./show-wifi-password.sh "My-Network-Name"

# Copy the current network's password to clipboard
./show-wifi-password.sh -c

# Display help information
./show-wifi-password.sh -h

# Show version information
./show-wifi-password.sh -v
```

## Security Considerations

This utility accesses your Keychain in a secure manner using macOS's built-in `security` command:

- macOS will prompt for your permission before accessing any stored passwords
- No passwords are stored or transmitted by this tool
- When using the clipboard option (`-c`), passwords remain in your clipboard only until overwritten

## Limitations

- **No Touch ID Integration**: The script uses the macOS `security` command which does not support Touch ID authentication. You will need to type your administrator password when prompted.
- **Password Entry Required**: Due to Keychain security requirements, you'll need to manually enter your administrator credentials each time you access a password - this is a security feature of macOS, not a bug.
- **Administrator Access**: Retrieving passwords from Keychain requires administrator privileges.

## Compatibility

Tested and verified on:
- macOS Sonoma (14.x)
- Should work on recent macOS versions (Monterey, Ventura)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to help improve this project.