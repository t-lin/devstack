#!/bin/sh
nova boot --flavor $1 --image $2 --key_name key1 --security_groups default --hint force_hosts=bmc-`hostname -f` --hint node_ids=$4 $3
nova list
