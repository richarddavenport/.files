#! /usr/bin/env zsh

# if macOS
echo /usr/local/bin/zsh | sudo tee -a /etc/shells

chsh -s /usr/local/bin/zsh
