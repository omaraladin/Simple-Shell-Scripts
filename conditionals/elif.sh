#!/usr/bin/env bash

COLOR=$1
USER_GUESS=$2

if [ $COLOR = "Blue" ]
then
  echo "You have a teste in Colours :)"
elif [ $COLOR = "Red" ]
then
  echo "You may be a Communist, I love it"
else
  echo "You don't have a taste in Colours :("
fi

if [ $USER_GUESS -lt 10 ]
then
  echo "Your Number is Less than 10"
elif [ $USER_GUESS -eq 13 ]
then
  echo "You've guessed it! "
else
  echo "Your Number is Greater or Equal to Ten"
fi

exit 0
