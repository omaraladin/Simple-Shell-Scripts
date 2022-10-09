#!/bin/bash
# put inactive hosts in a file in /tmp/inactiveHosts.txt
#in this order, for example
#HE2
#UK3
echo -e "\n\n\nDo you want me to just comment these inactive hosts in inventory_updated.txt file or delete them from file?\n"
echo -e "1) Comment\n2) Delete\n"
read -p 'Please choose a number: ' choice

case $choice in
	1)
		for i in $(cat /tmp/inactiveHosts.txt); do sed -e "/$i/ s/^#*/#/" -i /home/ansible/inventory.txt; done
		echo -e "\nDone\n"
		;;			
	2)
		for i in $(cat /tmp/inactiveHosts.txt); do sed -e "/$i/d" -i /home/ansible/inventory.txt; done
		echo -e "\nDone\n"
		;;
	*)
		echo -e "\nPlease choose a suitable number -_-''"
		;;
esac
