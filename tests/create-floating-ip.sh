#!/bin/bash

TENANT_ID=`keystone tenant-list | grep " admin " | cut -d "|" -f 2 | sed 's/[ ]//g'`
NET_ID=`quantum net-list -c id -c name -c tenant_id | grep " $TENANT_ID " | cut -d "|" -f 2 | sed 's/[ ]//g'`

quantum floatingip-create $NET_ID

quantum floatingip-list
