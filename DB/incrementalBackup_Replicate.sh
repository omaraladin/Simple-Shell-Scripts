#!/bin/bash

#Thanks to https://www.howtogeek.com/734838/how-to-use-encrypted-passwords-in-bash-scripts/
# and https://gist.github.com/corvax19/4275922
#And to https://blog.sqlbak.com/incremental-mysql-server-backup-via-binary-log
#Please Visit before using script

# This is the Telegram Notification function
function sendTeleMessage() {
OPTION=$1
ERR_LINE=$2

case "$OPTION" in
  "start")
  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Replicate Script started on Prod_DB at:
⏰ <b>$(date "+%c")</b>

script execution report will be sent when finished
"""
  ;;
  "fail")
  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Replicate Script on Prod_DB has Failed ❌ on line <b>$ERR_LINE</b>
exact failure time is:
<b>$(date "+%c")</b>

kindly, troubleshoot the issue
"""
  ;;
  "finish")
  curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Restore Script finished on DB2 at:
✅ <b>$(date "+%c")</b>

Binlogs Archived:
<b>$binlogs_without_Last</b>
Archive Name:
<b>$archiveName</b>

now DB2 cronjob will run to restore these binlogs at 00:55 kindly wait for it
"""
  ;;
  esac
}

#Telegram Credentials
TEL_TOKEN="00000000:AAAAAAAAAAAAAAAAAAAAAAAAAAA"
TEL_CHATID="-000000"

#Script log file position
logFile=/var/log/replicate_script/replicate_script.log

MY_DATE=$(date +%d-%m-%Y_%H-%M)
MY_VAR=$(cat /opt/test/value.txt | openssl enc -d -a -A -aes-256-cbc -md sha256 -k '4ncRypT!0n_St4iNg') || sendTeleMessage "fail" $LINENO

#Log
printf "\n\n" >> $logFile
echo "---------------------------------" >> $logFile
echo "Replicate Script started on: $(date '+%c')" >> $logFile

#Send Telegram Start Notification
sendTeleMessage "start" $LINENO

#path to directory with binary log files
binlogs_path=/var/log/mysql/
#path to backup storage directory
backup_folder=/var/backups/mysql/

#start writing to new binary log file
sshpass -p $MY_VAR mysql -p -E --execute='FLUSH BINARY LOGS;' mysql -p || sendTeleMessage "fail" $LINENO
#Log
echo "Binary logs has been flushed" >> $logFile

#get list of binary log files
binlogs=$(sshpass -p $MY_VAR mysql -p -E --execute='SHOW BINARY LOGS;' mysql -p | grep Log_name | sed -e 's/Log_name://g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') || sendTeleMessage "fail" $LINENO
#get binlogs without last one
binlogs_without_Last=`echo "${binlogs}" | head -n -1`
#Log
echo "binLogs to be archived are: $binlogs_without_Last" >> $logFile
#get the last active binary log file (which you do not have to copy)
binlog_Last=`echo "${binlogs}" | tail -n -1`
#form full path to binary log files
binlogs_fullPath=`echo "${binlogs_without_Last}" | xargs -I % echo $binlogs_path%`

archiveName=binlogs_$MY_DATE.zip

#compress binary logs into archive
zip $backup_folder/$archiveName $binlogs_fullPath || sendTeleMessage "fail" $LINENO
#Log
echo "binlogs are archived into $archiveName" >> $logFile

#delete saved binary log files
echo $binlog_Last | sshpass -p $MY_VAR xargs -I % mysql -p -E --execute='PURGE BINARY LOGS TO "%";' mysql -p || sendTeleMessage "fail" $LINENO
#Log
echo "binlogs have been flushed" >> $logFile

#send archived logs to destination server
scp -i /root/.ssh/id_test $backup_folder/binlogs_$MY_DATE.zip root@db2.example.com:/var/backups/to_import/ || sendTeleMessage "fail" $LINENO
#Log
echo "$archiveName has been send to DB2" >> $logFile

#Leave the last 4 archives just for safety
cd /var/backups/mysql/ && ls -1tr | head -n -4 | xargs -d '\n' rm -f --

#Send Telegram Finish Notification
sendTeleMessage "finish" $LINENO
