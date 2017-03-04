#!/bin/sh

case $1 in

	down)
		lux -m 10 -s 50
		;;

	up)
		lux -m 10 -a 50
		;;
esac	
