#! /usr/bin/env zsh

export PATH="$PATH:/home/linuxbrew/.linuxbrew"

function mksshkey () {
	ssh-keygen -t rsa -C "rad22684@gmail.com"
}

function showsshkey () {
	cat < ~/.ssh/id_rsa.pub
}
