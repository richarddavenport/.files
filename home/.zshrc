#! /usr/bin/env zsh

export PATH="$PATH:/home/linuxbrew/.linuxbrew"

function mksshkey () {
	ssh-keygen -t rsa -C "rad22684@gmail.com"
}

function showsshkey () {
	cat < ~/.ssh/id_rsa.pub
}

source <(antibody init)
# this block is in alphabetic order
antibody bundle caarlos0/ports kind:path
# antibody bundle caarlos0/zsh-git-fetch-merge kind:path
# antibody bundle caarlos0/zsh-git-sync kind:path
# antibody bundle caarlos0/zsh-mkc
# antibody bundle caarlos0/zsh-open-pr kind:path
antibody bundle lukechilds/zsh-nvm
# export NVM_DIR="/home/richard/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# antibody bundle mafredri/zsh-async
# antibody bundle rupa/z

antibody bundle zsh-users/zsh-completions
# fpath=(/usr/local/share/zsh-completions $fpath)

antibody bundle zsh-users/zsh-autosuggestions
# source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# these should be at last!
# antibody bundle sindresorhus/pure
antibody bundle zsh-users/zsh-syntax-highlighting
antibody bundle zsh-users/zsh-history-substring-search

antibody bundle denysdovhan/spaceship-prompt

###############################################################################
# exports                                                                     #
###############################################################################

# flutter
export PATH=$PATH:$HOME/flutter/bin
# android
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools

export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"

# Make vim the default editor.
export EDITOR='vim';

###############################################################################
# functions                                                                   #
###############################################################################

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
	function diff() {
		git diff --no-index --color-words "$@";
	}
fi;

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
	local port="${1:-4000}";
	local ip=$(ipconfig getifaddr en1);
	sleep 1 && open "http://${ip}:${port}/" &
	php -S "${ip}:${port}";
}

# Compare original and gzipped file size
function gz() {
	local origsize=$(wc -c < "$1");
	local gzipsize=$(gzip -c "$1" | wc -c);
	local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l);
	printf "orig: %d bytes\n" "$origsize";
	printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}

# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# UTF-8-encode a string of Unicode symbols
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

# `s` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function s() {
	if [ $# -eq 0 ]; then
		subl .;
	else
		subl "$@";
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		vim .;
	else
		vim "$@";
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# cpdvd "SharkTale(2004)"
function cpdvd () {
	cpdisc $1 dvd
}

# cpbr "SharkTale(2004)"
function cpbr () {
	cpdisc $1 bluray
}

# cpdisc "SharkTale(2004)" dvd
function cpdisc () {
	name=$1
	echo "Name of movie: $name"
	type=$2
	echo "Type of movie: $type"
	root="$PWD/$name"
	echo "Root folder: $root"
	mkvfolder="$root/$type"
	mkdir $root
	mkdir $mkvfolder
	mkmkv $mkvfolder
	if [ $? -eq 0 ]; then
		for mkv in ${mkvfolder}/*(.);
		do
			output="$root/${mkv:t:r}-$type.mkv"
			mkmovie $mkv $output
			if [ $? -eq 0 ]; then
				echo "Removing $input..."
				rm $input
			fi
		done
		rm -d $mkvfolder
	fi
	echo "All Done!"
}

# mkmkv location
# location is the location to save the titles
function mkmkv () {
	echo "Starting MakeMKV..."
	location=$1
	echo "MakeMKV location: $location"
	echo "MakeMKV command: makemkvcon mkv disc:0 all $location"
	makemkvcon mkv disc:0 all $location
	drutil tray eject
	echo "Success!"
}

# mkmovie input output
function mkmovie () {
	input=$1
	output=$2
	echo "Starting HandBrake..."
	echo "HandBrake command: handbrakecli --preset "Very Fast 1080p30" --input $input --output $output --format av_mkv --align-av --all-audio --subtitle scan,1,2,3,4,5,6,7,8,9 --subtitle-forced --subtitle-burned"
	handbrakecli --preset "Very Fast 1080p30" --input $input --output $output --format av_mkv --align-av --all-audio --subtitle scan,1,2,3,4,5,6,7,8,9 --subtitle-forced --subtitle-burned
}

###############################################################################
# google cloud platform                                                       #
###############################################################################

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'


export PATH="$PATH:/home/linuxbrew/.linuxbrew"
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
export ANDROID_HOME=$HOME/Android/Sdk
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

function mksshkey () {
	ssh-keygen -t rsa -C "rad22684@gmail.com"
}

function showsshkey () {
	cat < ~/.ssh/id_rsa.pub
}

## History wrapper
function zsh_history {
  local clear list
  zparseopts -E c=clear l=list

  if [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file
    echo -n >| "$HISTFILE"
    echo >&2 History file deleted. Reload the session to see its effects.
  elif [[ -n "$list" ]]; then
    # if -l provided, run as if calling `fc' directly
    builtin fc "$@"
  else
    # unless a number is provided, show all history events (starting from 1)
    [[ ${@[-1]-} = *[0-9]* ]] && builtin fc -l "$@" || builtin fc -l "$@" 1
  fi
}

# Timestamp format
case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='zsh_history -f' ;;
  "dd.mm.yyyy") alias history='zsh_history -E' ;;
  "yyyy-mm-dd") alias history='zsh_history -i' ;;
  "") alias history='zsh_history' ;;
  *) alias history="zsh_history -t '$HIST_STAMPS'" ;;
esac

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# The following lines were added by compinstall
zstyle :compinstall filename '/home/richard/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
