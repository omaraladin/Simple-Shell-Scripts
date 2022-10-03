#!/bin/bash

# Make sure curl is installed
# run the script with the path of the file to be sent
# for example: 
# ./sendTelegramCompressedPic.sh /home/user/Pictures/myPic.png
TOKEN="0000000000:AAAAAAAAAAAAAAAAAAAAA"
CHAT_ID="0000000"
for arg in "$@"
do
    curl -X POST -H "content-type: multipart/form-data" -F photo=@"$arg" -F chat_id=$CHAT_ID https://api.telegram.org/bot$TOKEN/sendPhoto
done
