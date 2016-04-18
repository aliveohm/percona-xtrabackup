#!/bin/sh
NOW=`date +%H`
DIR=/home/dir

#echo "Time Now : $NOW"

if [ "$NOW" -eq '14' ]; then
	if [ -d $DIR ]; then
		echo "Folder exists."
	else
		mkdir $DIR
		echo "Created folder"
	fi
elif ["$NOW" -eq '01']; then

	echo "NOT TIME"
fi



