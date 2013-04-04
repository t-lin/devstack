#!/bin/sh
# metric: temperature, running_vms, free_ram_mb
nova boot --flavor $1 --image $2 --key_name key1 --security_groups default --hint sch_metric=$3 $4
nova list
