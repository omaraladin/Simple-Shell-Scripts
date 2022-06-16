#!/bin/bash
# This will create SSH key pairs, according to line of strings written in a file
# Here I use hosts.txt as that file

while read host; do
        echo "$host"
        ssh-keygen -t rsa -N '' -f ~/.ssh/id_"$host" <<< y
done < hosts.txt