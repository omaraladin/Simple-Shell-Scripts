#!/usr/bin/bash

# Empty failed_hosts file from previous run
echo -n > failed_hosts.txt
echo "Started on $(date +'%d/%m/%y - %r') in UAE Timezone, below are unpingale servers:" > failed_hosts.txt

# Filter only Servers_IPs from inventory file and make a ping loop on them
for i in $(awk '{print $2}' /home/ansible/ops/inventory.txt | grep -vE '^$|\[' | cut -b 14-)
do

	# ping the IP with 3 packets and hide output
	ping -c 3 $i &>/dev/null

	# Grab exit code in status variable
	status=$?

	# Execute this if-statement when exit code of ping is not a success
	if [ $status != 0 ]
	then
		# Filter the Failed_IP alias e.g. dev1 and append in failed_hosts file
		server_name="$(grep "$i" /home/ansible/ops/inventory.txt | awk '{print $1}' | grep -Ev '^$|\[')"
		server_ip=$i
		server_info="${server_name}	-	${server_ip}"		
		echo $server_info >> failed_hosts.txt
	fi
done


# Send failed_hosts to Telegram Group

# Add failedi_hosts file to a Variable
telegramMessage="$(cat failed_hosts.txt)"
echo $telegramMessage

# Your-Ansible bot Token
token="0000000000:XXXXXXXXXXXXXXXXXXXXXXXXX"

# (Ansible Monitoring Notification) chatid
chatid="-000000000000"

# Send the Message using Your-Ansible bot
curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$chatid -d text="$telegramMesage"