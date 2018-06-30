#!/usr/bin/env zsh

function doIt() {
	rm -rf ~/.zshrc;
	ln -s ~/.files/.zshrc ~/.zshrc;
	source ~/.zshrc;
}

doIt
