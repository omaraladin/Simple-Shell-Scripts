#!/bin/bash
# Suggestion is that file name is hosts

while read host; do
        echo "$host"
        ssh-keygen -t rsa -N '' -f ~/.ssh/id_"$host" <<< y
done < hosts
