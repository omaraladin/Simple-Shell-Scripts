#!/bin/bash

for file in ./*.sh
do
	ls -lh "${file}" >> looping-`date +%Y-%m-%d`.log
done
exit 0
