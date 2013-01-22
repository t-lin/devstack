#!/bin/sh
nova boot --flavor $1 --image $2 --key_name key1 --security_groups default $3
nova list
