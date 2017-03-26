#!/bin/sh
#DEP setxkbmap tr cut
#OPT dunst dunstify

# Retrieve the current keymap
lang="$(setxkbmap -query | grep layout | tr -d ' ' | cut -f2 -d':')"
icon="" # requires font-awesome
id_file="/tmp/.dunst_lang.id" # used if dunstify is installed


# Make sure $lang isn't empty
if [[ -z $lang ]]; then
	echo "Error parsing keymap"
	exit 1
fi


# Toggle through keymaps
if   [[ $lang == us ]]; then lang="ca"; setxkbmap $lang
elif [[ $lang == ca ]]; then lang="us"; setxkbmap $lang

# Default language
else setxkbmap us
fi


# Notification; uses dunst and dunstify
if [[ -e $(which dunstify) ]]; then

	# ID for replacing notification
	id="$(cat $id_file)"

	# Notification text
	out="$icon $lang"

	# if ID is valid, it is replace with -r
	# -p prints the ID
	if [[ $id -gt 0 ]]; then
		dunstify -pr $id "$out" > $id_file
	else
		dunstify -p "$out" > $id_file
	fi

fi
