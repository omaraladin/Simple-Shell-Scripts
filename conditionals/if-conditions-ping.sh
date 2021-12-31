#!/bin/bash

read -p "Enter a Domain to ping: " Domain

ping -c 1 $Domain

if test "$?" -eq "0"; then
	echo -e "\n$Domain IP is reachable"
else
	echo -e "\n$Domain IP isn't reachable"
fi
exit
