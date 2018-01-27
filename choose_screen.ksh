#!/bin/bash

id=$( whoami )
screen_dir="/var/run/screen/S-${id}"

while [ 1 ]; do
	screens=""

	if [ -d $screen_dir ]; then
		screens=$( cd $screen_dir; ls | sort -t'.' -k2 )
	else
		screens=$(  screen -list | grep pts | sort -t'.' -k2 )
	fi

	if [ "XX$screens" != "XX" ]; then
		index=1
		echo "Select a screen, or 'n' for new screen:"
		for i in $( echo $screens | sort -t'.' -k2 ); do
			echo "$index $i"
			index=$(( $index + 1 ))
		done

		echo -n "Choice: "
		read choice
		if [ "$choice" = "n" ]; then
			screen -a -t $id -h 1000
		elif [[  "$choice" = n:* ]]; then
			name=${choice##*:}
			if [ ! -z "$name" ]; then
				screen -a -t $name -S $name -h 1000 -A -O
			fi
		elif [[  "$choice" = k:* ]]; then
			# iterate 
			set $screens
			choices=${choice##*:}
			for choice in $choices; do
				screen=$( eval echo \${$choice} )
				screen_pid=${screen%%.*}
				echo "Press return to remove screen $screen ($screen_pid)"
				read this
				kill -9 $screen_pid
				output=$( screen -wipe | tr -s '[:blank:]' | tr '[:blank:]' ' ' | tr '\n' '|' )
				sleep 0.25
				echo $output
				echo "Press return to continue"
				read this
			done
		else
			set $screens
			screen=$( eval echo \${$choice} )
			echo "screen: $screen"
			sleep 2
			screen -dR $screen
		fi
	else
		echo "No screens found, creating new screen"
		if [ $# -eq 1 ]; then
			screen -a -t $1 -S $1 -h 1000
		else
			echo -n "Screen name: "
			read choice
			screen -a -t $choice -S $choice -h 1000
		fi
	fi
done
