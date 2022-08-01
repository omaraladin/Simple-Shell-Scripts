#!/bin/bash

#Telegram function
function sendTeleMessage() {
OPTION=$1

case "$OPTION" in
  "down")
	  echo "$ALIAS with IP: $IP_ADDRESS is down and exited!"
	  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""<b>$ALIAS</b>
<code>$IP_ADDRESS</code>

is unreachable by me ❌, kindly report to Infra/ops Team.
	  """
  	  exit 1
  ;;

  "fix")
	  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""<b>$ALIAS</b>
<code>$IP_ADDRESS</code>

is reachable by me ✅,
the APPLICATION processs <b>wasn't running</b> ❌ so, I restarted it
kindly check again the service should be working now.
	  """
	  exit 0
  ;;
  "report")
	  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""<b>$ALIAS</b>
<code>$IP_ADDRESS</code>

is reachable by me ✅,
the APPLICATION processs <b>is already running</b> ✅
The service should be working normally, kindly double check.
          """
	  exit 0
  ;;
  esac
}

TEL_TOKEN="000000:AAAAAAAAAAAAAAAAAAAAAAAAAAAA"
TEL_CHATID="-00000000"
MY_VAR=$(cat ./marxism.txt | openssl enc -d -pbkdf2 -a -k "4ncryPT10N_StR1ng")

read -p 'Enter Service Alias: ' ALIAS
read -p 'Enter Server IP: ' IP_ADDRESS

#Checking reachability
sshpass -p $MY_VAR ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p 22 user@$IP_ADDRESS "whoami" || sendTeleMessage "down"

#If Process available a report message will be sent, if not it will be restarted and a Fix message will be sent 
sshpass -p $MY_VAR ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p 22 user@$IP_ADDRESS "pgrep APPLICATION_PROCESS" && sendTeleMessage "report"

#If script not exited, this means APPLICATION process wasn't running, this will restart the process and a Fix message will be sent
sshpass -p $MY_VAR ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p 22 user@$IP_ADDRESS "sh /opt/my_app/my_app.sh" && sendTeleMessage "fix"
