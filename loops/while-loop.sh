#!/usr/bin/env bash

COUNT=1

while [ $COUNT -le 10 ]
do
  echo "Count is $COUNT"
  touch $COUNT.txt

  ((COUNT++))
done

echo "While Loop is Done, $COUNT should'nt be printed!"
exit 0
