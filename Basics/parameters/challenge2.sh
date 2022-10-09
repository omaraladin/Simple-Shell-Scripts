#!/usr/bin/env bash

USER_INPUT=$1
COUNT=1

while [ $COUNT -le $USER_INPUT ]
do
  echo $COUNT
  ((COUNT++))
done

echo Loop is terminated last Number was $COUNT
