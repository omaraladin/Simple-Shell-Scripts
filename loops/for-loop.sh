#!/usr/bin/env bash

NAMES=$@

for i in $NAMES
do
  echo "Hello, $i"
done

echo "Foor Loop terminated, last value is $i"
