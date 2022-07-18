#!/bin/bash

#Thanks to https://www.howtogeek.com/734838/how-to-use-encrypted-passwords-in-bash-scripts/
#And to https://blog.sqlbak.com/incremental-mysql-server-backup-via-binary-log
#Please Visit before using script

# This is the script start notification function
function sendTeleMessage() {
OPTION=$1
ERR_LINE=$2
exactDate=$3

case "$OPTION" in
  "start")
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Restore Script started on DB2 at:
⏰ <b>$(date "+%c")</b>
script execution report will be sent when finished"""
  ;;
  "fail")
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Restore Script on DB2 has Failed ❌ on line <b>$ERR_LINE</b>
failure time is: <b>$(date "+%c")</b>
kindly, troubleshoot the issue
        """
        exit 1
  ;;
  "finish")
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Restore Script finished on DB2: ✅
<b>$(date "+%c")</b>
Archives Restored:
<b>$archivesToImport</b>
        """
  ;;
  "not found")
        curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_CHATID -d parse_mode="html" -d text="""Restore Script Exited on DB2:
<b>$(date "+%c")</b>
Reason for exit:
<b>/var/backups/to_import/ directory was found Empty!</b>
which means I have no binlogs to restore at DB2
kindly, check Prod_DB to see if the master_script is finished or not
        """
        exit 0
  ;;
esac
}

#Telegram Credentials
TEL_TOKEN="0000000000:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
TEL_CHATID="-000000000"

MY_VAR=$(cat /opt/test/value.txt | openssl enc -d -a -A -aes-256-cbc -md sha256 -k '4ncrEpti0N_Str1ng') || sendTeleMessage "fail" $LINENO $(date "+%c")

#Remember to avail this directory and log file first
logFile=/var/log/restore_script/restore_script.log

#Log
printf "\n\n" >> $logFile
echo "---------------------------------" >> $logFile
echo "Script started at $(date +%c)" >> $logFile

#Send Telegram Start Notification
sendTeleMessage "start" $LINENO $(date "+%c")

#store archives "ordered from oldest to newes"
archivesToImport=$(ls -tr /var/backups/to_import/)

#Handling the case when to_import directory is empty
if ! [ "$archivesToImport" ]; then
        echo "/var/backup/to_import/ is found empty, message also sent to telegram and script exited" >> $logFile
        sendTeleMessage "not found" $LINENO $(date "+%c")
fi

#As long as the code execution reached here, it means that /var/backups/to_import/ is not empty
#Log
echo "Archives To restore are: " >> $logFile
echo "$archivesToImport" >> $logFile

#Making sure that there's no logs directory remain from a previous execution
rm -rf /var/backups/to_import/logs

#Log, just making the log cute ^_^
printf "\n" >> $logFile

#Start a loop on the Archives found at to_import/ directory
for archive in $(ls -tr /var/backups/to_import/)
do
        #Log
        echo "Working on $archive ...." >> $logFile
        #unzipping to use mysql binlog files
        unzip /var/backups/to_import/$archive -d /var/backups/to_import/logs  || sendTeleMessage "fail" $LINENO $(date "+%c")
        #saving mysql binlogs to a variable
        binlogsOnThisArchive=$(ls /var/backups/to_import/logs/var/log/mysql/)
        cd /var/backups/to_import/logs/var/log/mysql/
        #Replicate logs to MySQL
        mysqlbinlog $binlogsOnThisArchive | sshpass -p $MY_VAR mysql -u root -p || sendTeleMessage "fail" $LINENO
        #Remove logs directory
        rm -rf /var/backups/to_import/logs
        #Move The Archive to imported/ directory
        mv /var/backups/to_import/$archive /var/backups/imported/$archive
        #Log
        echo "Done Importing $archive" >> $logFile
        echo "binlogs imported are:" >> $logFile
        echo "$binlogsOnThisArchive" >> $logFile
        printf "\n" >> $logFile
done

#Leave the recent 4 imported archives and delete the others
cd /var/backups/imported/ && ls -1tr | head -n -4 | xargs -d '\n' rm -f --

#Log
echo "Done replicating all Archives" >> $logFile

#Send Telegram Finish Notification
sendTeleMessage "finish" $LINENO $(date "+%c")
