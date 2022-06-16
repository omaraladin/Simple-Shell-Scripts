#!/bin/bash
# This Shell script add an inbound (Ingress) rule with the following context
# Input given as SecurityGroups(GroupId) in a file named ec2SecurityGroupsIds.txt
for i in `cat ec2SecurityGroupsIds.txt`
do
        echo $i

        # Adding for IPv4
        aws ec2 authorize-security-group-ingress --vpc-id vpc-xxxxxxxxx --group-name $i --protocol tcp --port 2022 --cidr 0.0.0.0/0

        # Adding for IPv6
        aws ec2 authorize-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=2022,ToPort=2022,Ipv6Ranges='[{CidrIpv6=::/0}]'

        echo "done for $i"
done
