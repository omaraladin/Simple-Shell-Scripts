#!/bin/bash

# Print a description of the INPUT Message
echo -e "Please Provide a Domain-Name or an IP Address:\n"

# Here the script will redirect the (Standard-Input) to the Variable (Domain)
read -p 'Domain: ' Domain

# Ping the Domain one time using c flag
ping -c 1 $Domain
