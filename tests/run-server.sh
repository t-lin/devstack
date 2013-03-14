#!/bin/sh
nova boot --flavor $1 --image $2 --key_name $3 --security_groups default $4
nova list
