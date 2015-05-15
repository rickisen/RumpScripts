#!/bin/bash

# script that takes a text file of "users without folders" and a rumpus.users text file.
# And then produces a new rumpus.users file without those lines that contain 
# a username from the first file.

#- varaibles
	# read from input args
	rumpusFile="$1"
	badUsers="$2"
	output="$3"
	cleanList="/tmp/CleanRumpus.txt"
	cleanOutput="/tmp/CleanRumpusOut.txt"

	#syntax error
	if [[ -z "$1" || -z "$2" || -z "$3" || "$1" == "-h" || "$1" == "--help" ]]
	then 
		echo "bad syntax!, example:"
		echo "./scriptname.sh path/to/Rumpus.users path/to/Users_without_folders.txt path/to/new-Rumpus.users "
		exit 1
	fi

	#verify input
	if [ -e "$output" ]
	then
		read -p " Warning! about to overwrite $output do you wich to proceed? Y or N : " -n 1
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
		    echo " Exiting..."
		    exit 1
		else
		    echo " Resuming"
		    sleep 2
		fi
	elif [[ ! -e "$badUsers" || ! -e "$rumpusFile"  ]]
	then
		echo "Bad input, of or both of the input files does not exist!"
		exit 1 
	fi

#- main loop
	#- prepair for looping 
	rm    "$output" "$cleanList" "$cleanOutput"
	touch "$output" "$cleanList" "$cleanOutput"
	cat "$rumpusFile" | tr '\r' '\n'  > "$cleanList"

	# loop through rumpus file
	while read line 
	do
		# check if first word exists in userList
		# if it does, then don't write this line to the new file
		firstWord="$( echo "$line" | awk '{ print $1 }' )"
		if $(grep -q "$firstWord" "$badUsers" )
		then
			echo "Filtered out $firstWord"
		else
			echo "$line" >> "$cleanOutput"
		fi

	done < "$cleanList" 

	# Format the output for dos compatability
	cat "$cleanOutput" | tr '\n' '\r' > "$output"

#- clean up
	rm  "$cleanList" "$cleanOutput"
