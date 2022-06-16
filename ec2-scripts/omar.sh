#!/bin/bash
#!/bin/bash
# This Shell script revokes (Removes) an inbound (Ingress) rule with the following context
# Input given as SecurityGroups(GroupId) in a file named ec2SecurityGroupsIds.txt

for i in `cat ec2SecurityGroupsIds.txt`
do
	echo $i
	echo "Done for $i"
done
