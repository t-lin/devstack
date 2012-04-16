#!/bin/bash

set -e

function interfaces {
  ip link show | grep -iv LOOPBACK | grep '^[0-9]:\s' | cut -d " " -f 2 |\
    cut -d ":" -f 1
}

function interface_count {
  interfaces | wc -l
}

function ip_address {
  ip addr show $1 | grep "inet\s"  | sed "s/^\s\+//g" | cut -d " " -f 2 |\
    cut -d "/" -f 1
}

function sanity_check {
  if [ ! -f $PWD/stack.sh ]; then
    echo "Run this script from devstack's root: sample/of/local.sh"
    exit 1
  fi

  INTS=$(interface_count)
  if [[ $INTS < 1 ]]; then
    echo "You have less than 2 interfaces. This script needs at least two\
      network interfaces."
    exit 1
  fi
}

function interface_exists {
  ip addr show $1
}

sanity_check

OF_DIR=`dirname $0`

AGENT=0

while getopts ":a" opt; do
  case $opt in
    a)
      echo "Creating localrc for agent."
      AGENT=1
      ;;
  esac
done


echo "Please enter a password (this is going to be used for all services):"
read PASSWORD

echo "Which interface should be used for vm connection (ie, "$(interfaces)")?"
read FLAT_INT

if ! interface_exists $FLAT_INT; then
  echo "There is no interface "$FLAT_INT
  exit 1
fi

HOST_IP=$(ip_address eth0)
echo "What's the ip address of this machine? [$HOST_IP]"
read HOST_IP_READ
if [ $HOST_IP_READ ]; then
  HOST_IP=$HOST_IP_READ
fi

if [[ $AGENT == 0 ]]; then
  cp $OF_DIR/ctrl-localrc localrc
  sed -i -e 's/\${PASSWORD}/'$PASSWORD'/g' localrc
  sed -i -e 's/\${HOST_IP}/'$HOST_IP'/g' localrc
  sed -i -e 's/\${FLAT_INTERFACE}/'$FLAT_INT'/g' localrc
else
  echo "What's the controller's ip address?"
  read CTRL_IP_ADDRESS

  cp $OF_DIR/agent-localrc localrc
  sed -i -e 's/\${PASSWORD}/'$PASSWORD'/g' localrc
  sed -i -e 's/\${HOST_IP}/'$HOST_IP'/g' localrc
  sed -i -e 's/\${CONTROLLER_HOST}/'$CTRL_IP_ADDRESS'/g' localrc
  sed -i -e 's/\${FLAT_INTERFACE}/'$FLAT_INT'/g' localrc

  echo "0"
fi

echo "Now run ./stack.sh"


