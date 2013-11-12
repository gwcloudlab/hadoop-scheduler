#!/bin/bash

hosts="151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170"

#ssh-keygen
for host_dst in $hosts
do
	ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@192.168.1.$host_dst
done
