!/usr/bin/bash

#Thanks to https://www.howtogeek.com/734838/how-to-use-encrypted-passwords-in-bash-scripts/
#And to https://blog.sqlbak.com/incremental-mysql-server-backup-via-binary-log
#Please Visit before using script

# This is the script start notification function
function sendStartTeleMessage() {
OPTION=$1
ERR_LINE=$2

case $OPTION in

  start)
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text='''<b>Replication Script started on:</b> ⏰ '$MY_DATE'
        script execution report will be sent when finished'''
  ;;
  fail)
         curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text='''<b>Replication Script has Failed ❌ on line '$ERR_LINE'</b>
        <b>Failure Exact Time is:</b> ⏰ '$(date +%d-%m-%Y_%H-%M)'
        kindly, troubleshoot the issue
        '''
        exit 1
  ;;
  finish)
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text='''<b>Replication Script finished on:</b> ✅ '$(date +%d-%m-%Y_%H-%M)'
        <b>Binlogs Archived:</b> '$binlogs_without_Last'
        <b>Archive Name:</b> binlogs_'$MY_DATE'
        Archive is sent to DB2 successfully!
        kindly, wait for DB2 cronjob to restore binlogs 👌
        '''
  ;;
esac
}


#Telegram Credentials
TEL_TOKEN="00000000:AAAAAAAAAAAAAAAAAAAAAAAAAAA"
TEL_CHATID="-000000"

MY_DATE=$(date +%d-%m-%Y_%H-%M)
MY_VAR=$(cat /opt/test/value.txt | openssl enc -d -a -A -aes-256-cbc -md sha256 -k '4ncrypti0n_Str1ng') || sendStartTeleMessage "fail" $LINENO

#Send Telegram Start Notification
curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text='''<b>Replication Script started on:</b> ⏰ '$MY_DATE'
script execution report will be sent when finished'''

#path to directory with binary log files
binlogs_path=/var/log/mysql/
#path to backup storage directory
backup_folder=/var/backups/mysql/

#start writing to new binary log file
sshpass -p $MY_VAR mysql -p -E --execute='FLUSH BINARY LOGS;' mysql -p || sendStartTeleMessage "fail" $LINENO

#get list of binary log files
binlogs=$(sshpass -p $MY_VAR mysql -p -E --execute='SHOW BINARY LOGS;' mysql -p | grep Log_name | sed -e 's/Log_name://g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') || sendStartTeleMessage "fail" $LINENO
#get binlogs without last one
binlogs_without_Last=`echo "${binlogs}" | head -n -1`
#get the last active binary log file (which you do not have to copy)
binlog_Last=`echo "${binlogs}" | tail -n -1`
#form full path to binary log files
binlogs_fullPath=`echo "${binlogs_without_Last}" | xargs -I % echo $binlogs_path%`

#compress binary logs into archive
zip $backup_folder/binlogs_$MY_DATE.zip $binlogs_fullPath || sendStartTeleMessage "fail" $LINENO

#delete saved binary log files
echo $binlog_Last | sshpass -p $MY_VAR xargs -I % mysql -p -E --execute='PURGE BINARY LOGS TO "%";' mysql -p || sendStartTeleMessage "fail" $LINENO

#send archived logs to destination server
scp -i /root/.ssh/id_test -P 2812 $backup_folder/binlogs_$MY_DATE.zip root@db2.example.com:/var/backups/dest_mysql/ || sendStartTeleMessage "fail" $LINENO

#Leave the last 4 archives just for safety
cd /var/backups/mysql/ && ls -1tr | head -n -4 | xargs -d '\n' rm -f --

#Send Telegram Finish Notification
curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text='''<b>Replication Script finished on:</b> ✅ '$(date +%d-%m-%Y_%H-%M)'
<b>Binlogs Archived:</b> '$binlogs_without_Last'
<b>Archive Name:</b> binlogs_'$MYDATE'
Archive is sent to DB2 successfully!
kindly, wait for DB2 cronjob to restore binlogs 👌
'''
