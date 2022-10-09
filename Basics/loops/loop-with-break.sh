#!/usr/bin/env bash

NAMES=$@

for NAME in $NAMES
do
  if [ $NAME = "Trump" ]
  then
    echo Name is $NAME, so we will Break and Exit the Loop
    break
  fi
  echo "Hello, $NAME"
done
