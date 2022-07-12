#!/usr/bin/bash

#Thanks to https://www.howtogeek.com/734838/how-to-use-encrypted-passwords-in-bash-scripts/
#And to https://blog.sqlbak.com/incremental-mysql-server-backup-via-binary-log
#Please Visit before using script

TEL_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
TEL_CHATID="-00000000000"
MY_DATE=$(date +%d-%m-%Y_%H-%M-%S)
MY_VAR=$(cat /opt/test/value.txt | openssl enc -d -a -A -aes-256-cbc -md sha256 -k '&Pp5sooZS&[~"oH~A#]^')
#path to directory with binary log files
binlogs_path=/var/log/mysql/
#path to backup storage directory
backup_folder=/var/backups/mysql/
#start writing to new binary log file
sshpass -p $MY_VAR mysql -p -E --execute='FLUSH BINARY LOGS;' mysql -p
#get list of binary log files
binlogs=$(sshpass -p $MY_VAR mysql -p -E --execute='SHOW BINARY LOGS;' mysql -p | grep Log_name | sed -e 's/Log_name://g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
#get binlogs without last one
binlogs_without_Last=`echo "${binlogs}" | head -n -1`
#get the last active binary log file (which you do not have to copy)
binlog_Last=`echo "${binlogs}" | tail -n -1`
#form full path to binary log files
binlogs_fullPath=`echo "${binlogs_without_Last}" | xargs -I % echo $binlogs_path%`
#compress binary logs into archive
zip $backup_folder/binlogs_$MY_DATE.zip $binlogs_fullPath
#delete saved binary log files
echo $binlog_Last | sshpass -p $MY_VAR xargs -I % mysql -p -E --execute='PURGE BINARY LOGS TO "%";' mysql -p
#send archived logs to destination server
scp -i /root/.ssh/id_private_replica_key $backup_folder/binlogs_$MY_DATE.zip root@MY_REPLICA_SERVER:/var/backups/dest_mysql/
#Leave the last 4 archives just for safety
cd /var/backups/mysql/ && ls -1tr | head -n -4 | xargs -d '\n' rm -f --
#Notify Telegram Group
curl -s -X POST https://api.telegram.org/bot$TEL_TOKEN/sendMessage -d chat_id=$TEL_TOKEN -d text="$binlogs_without_Last now archived and sent to Replica_DB\nScript started on $MY_DATE\NFinished on $(date +%d-%m-%Y_%H-%M-%S)"
