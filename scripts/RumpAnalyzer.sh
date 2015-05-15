#!/bin/bash

#-Description-------------------
# A script that aims to aid in cleaning up a rumpus ftp folder
# it does this by looking in the rumpus user list and 
# makes a list of users that have no homefolder, 
# and looks in the home folder path, and reports
# all folders that are not mentioned in the userlist.

#-Startup variables -------------
#--input
listDestination="$3"
#--Paths
rumpusList="$1"
#rumpusList=/usr/local/Rumpus/Rumpus.users
ftpHome="$2"
#ftpHome=/Volumes/FTP/FTP/home/
activePaths=/tmp/activePaths.txt
orphanedPaths=/tmp/orphanedPaths.txt
homelessUsers=/tmp/homelessUsers.txt
cleanList=/tmp/cleanList.txt

#-input validation
	#syntax error
	if [[ -z "$1" || -z "$2" || -z "$3" || "$1" == "-h" || "$1" == "--help" ]]
	then 
		echo "bad syntax!, example:"
		echo ""
		echo "./scriptname.sh path/to/Rumpus.users path/to/FTP/home/ path/to/output-files/ "
		echo ""
		echo "Usually theese are /usr/localRumpus/Rumpus.users, and /Volumes/FTP/FTP/home/"
		exit 1
	fi

	if [[ ! -e "$rumpusList" || ! -d "$ftpHome"  ]]
	then
		echo "Bad input, either the input rumpus-file does not exist, or the supplied ftp-path is incorrect!"
		exit 1 
	fi

	#verify input

#-Loop preparation
#--- replace old return files for a clean enviorment
rm    "$activePaths" "$homelessUsers" "$orphanedPaths" "$cleanList" &>/dev/null
touch "$activePaths" "$homelessUsers" "$orphanedPaths" "$cleanList"

#--- Generate a clean list of user homes from rumpus list
cat "$rumpusList" | tr '\r' '\n'  > "$cleanList"
cat "$cleanList" | awk '{print $3}' >> "$activePaths" 

#- Folder loop -----------------
#--- loop through the folders in the home folder
echo "Checking for orphaned folders"
for File in $ftpHome/*
do
	if [ -d "$File" ] # Continue if "File" is a (existing) folder
	then
#------- check if it exist in the user list
		if $(grep -q $(basename "$File") "$activePaths") 
		then
			echo "$(basename "$File") looks like it's in use"
		else
#------- if not, report it in the return list
			echo "$(basename "$File")" >> "$orphanedPaths"
		fi
	fi
done

#- User loop -----------------
#------ Check for users without home folders
homeFolder="" ; userName=""
echo "Checking for homeless users"
while read line  # reads every line in the rumpus list
do
	homeFolder=`echo "$line" | awk '{ print $3}'`
	userName=`echo "$line" | awk '{ print $1}'`

	if [ -d "$homeFolder"  ]
	then
		echo "$userName has a home folder"
	else
		echo "$userName" >> "$homelessUsers"
	fi
done < "$cleanList"

#-Return results ---------------
if [ -d "$listDestination" ]
then
# -- If a correct output folder was submitted, write to that 
	cp "$homelessUsers" "$listDestination/Users_without_folders.txt"
	cp "$orphanedPaths" "$listDestination/Folders_without_users.txt"
else
# -- else to current directory
	cp "$homelessUsers" ./Users_without_folders.txt
	cp "$orphanedPaths" ./Folders_without_users.txt
fi

#-Clean up ------------------
#-- Delete temporary text files.
	rm "$activePaths" "$homelessUsers" "$orphanedPaths" "$cleanList"
