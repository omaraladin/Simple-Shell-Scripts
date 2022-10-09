#!/usr/bin/env bash

NAMES=$@

for NAME in $NAMES
do
  if [ $NAME = "Trump" ]
  then  
    continue
  fi
  echo "Hello, $NAME"
done
