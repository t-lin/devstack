#!/bin/bash

TOP_DIR=$(cd $(dirname "$0") && pwd)

source $TOP_DIR/stackrc
source $TOP_DIR/functions
source $TOP_DIR/localrc

source $TOP_DIR/openrc admin admin $REGION_NAME $KEYSTONE_AUTH_HOST

IGNORE_TENANT_LIST="invisible_to_admin,demo2,service,admin,demo1,savi"
TENANTS=$(keystone tenant-list | grep True | get_field 2)
ROUTER_ID=$(quantum router-list | grep ' router1 ' | get_field 1)

echo "tenant: " $TENANTS
echo "router id: " $ROUTER_ID

for tenant in $TENANTS 
do
    echo "tenant to be processed  $tenant "

    if [[ ,${IGNORE_TENANT_LIST}, =~ ,${tenant}, ]]; then
        continue
    fi

    echo "tenant to be really processed  $tenant "

    TENANT_ID=$(keystone tenant-list | grep " $tenant " | get_field 1)
    echo $TENANT_ID
    FIXED_RANGE=$(keystone tenant-get $TENANT_ID | grep "ip:$REGION_NAME" | get_field 2)
    echo $FIXED_RANGE

    if [[ $TENANT_ID != "" && $FIXED_RANGE != "" ]]; then
        NET_ID=$(quantum net-list | grep ${tenant}-net)
        if [[ $NET_ID != "" ]]; then
           echo "network exists for tenant $tenant"
           continue
        fi
        echo "creating network and subnet"
        NET_ID=$(quantum net-create --tenant_id $TENANT_ID ${tenant}-net | grep ' id ' | get_field 2)
        echo $NET_ID

        SUBNET_ID=$(quantum subnet-create --tenant_id $TENANT_ID --name ${tenant}-subnet --ip_version 4 $NET_ID $FIXED_RANGE --dns_nameservers list=true $DNS_NAME_SERVER | grep ' id ' | get_field 2)
        echo $SUBNET_ID
        
        if is_service_enabled q-l3; then
           quantum router-interface-add $ROUTER_ID $SUBNET_ID
        fi
    fi

done
