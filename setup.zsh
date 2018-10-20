#! /usr/bin/env zsh

# Symlink
rm -rf $HOME/.zshrc
ln -s $HOME/.files/.zshrc $HOME/.zshrc

sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
