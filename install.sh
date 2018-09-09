#!/bin/sh

echo "Setting up your Mac..."

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Installing Xcode command line tools..."	
sudo xcode-select --install
sudo xcodebuild -license accept

echo "Updating macOS..."
sudo softwareupdate -i -a

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Make ZSH the default shell environment
chsh -s $(which zsh)

# Symlink the Mackup config file to the home directory
rm -rf $HOME/.mackup.cfg
ln -s $HOME/.files/.mackup.cfg $HOME/.mackup.cfg

# Run restore application settings
mackup restore

# Set macOS preferences
# We will run this last because this will reload the shell
source .macos
