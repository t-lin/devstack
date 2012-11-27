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
   FLOATING_IP_ID=`quantum floatingip-list | grep "$FLOATING_IP" | cut -d "|" -f 2 | sed 's/[ ]//g'`

   quantum floatingip-disassociate $FLOATING_IP_ID

   quantum floatingip-list
fi

