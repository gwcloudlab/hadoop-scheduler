#!/bin/bash

hosts="222 223"

ssh-keygen
for host_dst in $hosts
do
	ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@192.168.1.$host_dst
done
