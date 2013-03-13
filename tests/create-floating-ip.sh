#!/bin/bash

quantum floatingip-list

echo "based on teh above floating IP list, do you still want to create a new one? ([y]/n)"

read CREATE_NEW
if [[ "$CREATE_NEW" == "n" || "$CREATE_NEW" == "N" ]]; then
exit 1
fi

TENANT_ID=`keystone token-get | grep tenant_id | awk '{print $4 }'`
echo $TENANT_ID
NET_ID=`quantum net-list -c id -c name -c subnets | grep ext_net | awk '{print $2}'`
echo $NET_ID

quantum floatingip-create $NET_ID

quantum floatingip-list
