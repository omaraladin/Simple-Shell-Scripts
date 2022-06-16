#!/bin/bash
# This Shell script revokes (Removes) an inbound (Ingress) rule with the following context
# Input given as SecurityGroups(GroupId) in a file named ec2SecurityGroupsIds.txt

for i in `cat ec2SecurityGroupsIds.txt`
do
        echo $i

        # Adding for IPv4
        aws ec2 revoke-security-group-ingress --group-id $i --protocol tcp --port 22 --cidr 0.0.0.0/0

        # Adding for IPv6
        aws ec2 revoke-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,Ipv6Ranges='[{CidrIpv6=::/0}]'

        echo "Done for $i"
done
