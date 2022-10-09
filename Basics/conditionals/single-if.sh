#!/usr/bin/env bash

COLOR=$1
USER_GUESS=$2

if [ $COLOR = "Blue" ]
then
  echo "You have a teste in Colours :)"
else
  echo "Your taste isn't good in Colours :("
fi

if [ $USER_GUESS -lt 10 ]
then
  echo "Your Number is Less than 10"
else
  echo "Your Number is Greater or Equal to 10"
fi

exit 0
