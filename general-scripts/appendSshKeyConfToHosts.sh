#!/bin/bash
# This script assumes that the configured ssh keys are owned by a user named ansible
# and keys location is in /home/ansible/.ssh/id_hostName_rsa
while IFS= read -r -d $'\n' -u 9
do
    #If line starts with "[" then it means it is an AnsibleHostGroup definition 
    #so prints a new line from the last ansibleHostGroupHosts and echos the line AS IT IS
	if [[ $REPLY == [* ]]
	then
		echo -e "\n$REPLY"

    #If line starts with "#" then it means it is a comment 
    #so echos the line AS IT IS
	elif [[ $REPLY == \#* ]]
	then
		echo "$REPLY" #>> final.txt;

    #If above conditions are not met then this is the line which starts with a host ALIAS
    #so append the string to the line, see stringAppend variable
	elif [[ $REPLY == [a-z]* || $REPLY == [A-Z]* ]]
#		echo $REPLY		
#		echo -e "Modified to:"
		serverName=$(echo $REPLY | awk '{ print $1 }')
		stringAppend="ansible_ssh_private_key_file=/home/ansible/.ssh/id_${serverName}_rsa"
		echo "$REPLY    $stringAppend"
	fi

#The ssh-unconfigured inventory file should be given as an input
done 9< inventory2.txt
