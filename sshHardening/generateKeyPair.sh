#!/bin/bash
# Don't make a one-line code, make a readable and reusable code
host_name=$1
key_path="/home/ansible/.ssh/id_${host_name}"
#If key-pair exists, do not overwrite it
if [ -f "$key_path" ]; then
	exit 0
#Else generate it
else
	ssh-keygen -t rsa -N '' -b 4096 -C "${host_name} public key" -f $key_path
fi
#echo $host_name
#echo $key_name
