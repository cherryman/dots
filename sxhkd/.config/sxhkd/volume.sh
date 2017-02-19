#!/bin/sh
#requires dunst with dunstify & font-awesome

case $1 in
	"up")
		amixer set Master 2%+
		;;
	"down")
		amixer set Master 2%-
		;;
esac

ID_FILE="$(dirname $0)/.dunst_volume.id"
ICON_MUTE=""
ICON_LOW=""
ICON_HIGH=""

ID="$(cat $ID_FILE)"
if [[ ! ($ID -gt 0) ]]; then
	ID=1
fi

VOLUME="$(amixer get Master | grep -E -o '[0-9]{1,3}' | tail -1)"
case $VOLUME in
	0)
		dunstify -p -r $ID "$ICON_MUTE $VOLUME" > $ID_FILE
		;;
	[0-3]*)
		dunstify -p -r $ID "$ICON_LOW $VOLUME" > $ID_FILE
		;;
	[4-9]*)
		dunstify -p -r $ID "$ICON_HIGH $VOLUME" > $ID_FILE
		;;
esac
