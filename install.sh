#!/bin/sh

echo "Setting up your Mac..."

# Install software
source .brew

# Restore backups
source .mackup

# Make ZSH the default shell environment
source .sh

# Set macOS preferences
source .macos
