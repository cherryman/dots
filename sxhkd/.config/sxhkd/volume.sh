#!/bin/sh
#requires dunst with dunstify & font-awesome

case $1 in
	"up")
		amixer set Master 2%+ unmute
		;;
	"down")
		amixer set Master 2%- unmute
		;;
	"mute")
		amixer set Master mute
		;;
esac


ID_FILE="/tmp/.dunst_volume.id"
ICON_MUTE=""
ICON_LOW=""
ICON_HIGH=""

ID="$(cat $ID_FILE)"
[[ $ID -gt 0 ]] || ID=1


if [[ -e "$(amixer get Master | grep '[off]')" ]]; then
	VOL="mute"
else
	VOL="$(amixer get Master | awk '$0~/%/{print $4}' | tr -d '[]%')"
fi

case $VOL in
	0|mute)
		dunstify -p -r $ID "$ICON_MUTE $VOL" > $ID_FILE
		;;
	[4-9][0-9])
		dunstify -p -r $ID "$ICON_HIGH $VOL" > $ID_FILE
		;;
	*)
		dunstify -p -r $ID "$ICON_LOW  $VOL" > $ID_FILE
		;;
esac
