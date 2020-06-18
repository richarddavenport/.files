#!/usr/bin/env zsh

function doIt {
	ln -fs ~/.files/.zshrc ~/.zshrc;
	ln -fs ~/.files/.p10k.zsh ~/.p10k.zsh;
}

doIt;
unset doIt;
