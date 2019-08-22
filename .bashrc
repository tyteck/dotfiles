# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# What platform are we running on.
export OS=`uname`

# History settings.
HISTCONTROL='erasedups:ignoreboth' # Erase duplicates
HISTFILESIZE=50000                 # Max size of history file
HISTIGNORE=?:??                    # Ignore one and two letter commands
HISTSIZE=50000                     # Amount of history to save
# Note, to immediately append to history file see 'prompt' function below.


# Enable the useful Bash features:
#  - autocd, no need to type 'cd' when changing directory
#  - cdspell, automatically fix directory typos when changing directory
#  - direxpand, automatically expand directory globs when completing
#  - dirspell, automatically fix directory typos when completing
#  - globstar, ** recursive glob
#  - histappend, append to history, don't overwrite
#  - histverify, expand, but don't automatically execute, history expansions
#  - nocaseglob, case-insensitive globbing
#  - no_empty_cmd_completion, don't TAB expand empty lines
#  - checkwinsize, check the window size after each command and, if necessary, update 
# 		the values of LINES and COLUMNS.
shopt -s autocd cdspell checkwinsize direxpand dirspell globstar histappend histverify \
    nocaseglob no_empty_cmd_completion
shopt -s checkwinsize

# Set the appropriate umask.
umask 002

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ==================================================
# micromania specific configuration
micromania_conf=~/.micromania.conf
if [ -f $micromania_conf ]; then
	# this file should not be versionned
    . $micromania_conf
fi

# ==================================================
# wsl conf
wsl_conf=~/.wsl_conf
if [ -f $wsl_conf ]; then
	# this file should not be versionned
    . $wsl_conf
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
