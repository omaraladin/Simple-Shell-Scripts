#!/bin/bash

# Saving Time in a Variable, Time is a big lie, it is just relative and it is not there
TIME=`date '+%d-%m-%Y-%T'`

# Exporting the Database
/usr/bin/mysqldump -uroot -p'PASSSWORD' my_db > /var/backup/my_db${TIME}.sql

# Backing up the Database in AWS S# bucket
/usr/local/bin/aws s3 cp /var/backup/my_db${TIME}.sql s3://my-storage/db-backup/my_db${TIME}.sql

# Removing the oldest DB backup in Backup Directory
rm -f `ls -ltr /var/backup | tail -n 1 | awk '{ print $NF }'`