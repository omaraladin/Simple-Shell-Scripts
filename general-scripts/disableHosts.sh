#!/bin/bash
# put inactive hosts in a file in /tmp/inactiveHosts.txt
#in this order, for example
#HE2
#UK3
HOME_VAR=/home/ansible/servers_ops
echo -e "\n\n\nDo you want me to just comment these inactive hosts in inventory.txt file or delete them from file?\n"
echo -e "1) Comment\n2) Delete\n"
read -p 'Please choose a number: ' choice
DATE=$(date +%m-%d-%Y)
echo -e "Backing up inventory.txt to $HOME_VAR/backup/inventory.txt-$DATE"
cp $HOME_VAR/hosts/inventory.txt $HOME_VAR/hosts/backup/inventory.txt-$DATE
case $choice in
	1)
		for i in $(cat /tmp/inactiveHosts.txt); do sed -e "/$i/ s/^#*/#/" -i $HOME_VAR/hosts/inventory.txt; done
		echo -e "\nDone\n"
		;;			
	2)
		for i in $(cat /tmp/inactiveHosts.txt); do sed -e "/$i/d" -i $HOME_VAR/hosts/inventory.txt; done
		echo -e "\nDone\n"
		;;
	*)
		echo -e "\nPlease choose a suitable number -_-''"
		;;
esac
