#!/bin/bash
# Two arguments expected:
#    1. Floating IP address
#

if [[ -n "$1" ]]; then
   FLOATING_IP=$1
else
   echo "Must specify first parameter (Floating IP address)"
   ERR=1
fi

if [[ -z "$ERR" ]]; then
   FLOATING_IP_ID=`quantum floatingip-list | grep "$FLOATING_IP" | awk '{print $2}'`

   quantum floatingip-disassociate $FLOATING_IP_ID

   quantum floatingip-list
fi

