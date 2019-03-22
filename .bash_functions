#!/bin/bash

# this function will display one title the way we can't miss it on term
title() {
	format="\e[1;100m"
	normal="\e[0m"
	echo -e "$format=== $1 ===$normal"
}

# Error (white on red) will precede the message
error() {
	format="\e[1;41m"
	normal="\e[0m"
	echo -e "${format}Error :$normal $1"
}

# Warning (white on orange) will precede the message
warning() {
	format="\e[30;48;5;166m"
	normal="\e[0m"
	echo -e "${format}Warning :$normal $1"
}

success() {
	format="\e[30;48;5;82m"
	normal="\e[0m"
	echo -e "${format}Success :$normal $1"
}

notice() {
	format="\e[1;44m"
	normal="\e[0m"
	echo -e "${format}Notice :$normal $1"
}