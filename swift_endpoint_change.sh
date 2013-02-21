#!/bin/sh
PUBLICURL=$1
INTERNALURL=$2
ADMINURL=$2
keystone endpoint-list | grep "8080/v1/AUTH" | grep $OS_REGION_NAME | awk '{ print $2 }' | xargs -I {} keystone endpoint-delete {}
SW_SERVICE_ID=`keystone service-list | grep swift | awk '{ print $2 }'`
keystone endpoint-create --region $OS_REGION_NAME --service-id $SW_SERVICE_ID --publicurl  "http://$PUBLICURL:8080/v1/AUTH_\$(tenant_id)s" --internalurl "http://$INTERNALURL:8080/v1/AUTH_\$(tenant_id)s" --adminurl "http://$ADMINURL:\$(admin_port)s/v2.0"
keystone endpoint-list
