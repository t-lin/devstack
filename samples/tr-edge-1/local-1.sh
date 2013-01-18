#!/usr/bin/env bash

# Sample ``local.sh`` for user-configurable tasks to run automatically
# at the sucessful conclusion of ``stack.sh``.

# NOTE: Copy this file to the root ``devstack`` directory for it to
# work properly.

# This is a collection of some of the things we have found to be useful to run
# after stack.sh to tweak the OpenStack configuration that DevStack produces.
# These should be considered as samples and are unsupported DevStack code.

# Keep track of the devstack directory
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Use openrc + stackrc + localrc for settings
source $TOP_DIR/stackrc

# Destination path for installation ``DEST``
DEST=${DEST:-/opt/stack}


# Import ssh keys
# ---------------

# Import keys from the current user into the default OpenStack user (usually
# ``demo``)

# Get OpenStack auth
source $TOP_DIR/openrc admin demo1 $REGION_NAME $KEYSTONE_AUTH_HOST

# Add first keypair found in localhost:$HOME/.ssh
for i in $HOME/.ssh/id_rsa.pub $HOME/.ssh/id_dsa.pub; do
    if [[ -f $i ]]; then
        nova keypair-add --pub_key=$i `hostname`
        break
    fi
done


# Create A Flavor
# ---------------

# Name of new flavor
# set in ``localrc`` with ``DEFAULT_INSTANCE_TYPE=m1.micro``
#MI_NAME=m1.micro

# Create micro flavor if not present
#if [[ -z $(nova flavor-list | grep $MI_NAME) ]]; then
#    nova flavor-create $MI_NAME 6 128 0 1
#fi
# Other Uses
# ----------

if [[ "$KEYSTONE_TYPE" = "LOCAL" ]]; then
   local_settings=$HORIZON_DIR/openstack_dashboard/local/local_settings.py
   IFS=","
   sudo sh -c "echo \"AVAILABLE_REGIONS = [\" >> $local_settings"
   for region in $REGIONS
   do
     sudo sh -c "echo \"     ('$SERVICE_ENDPOINT', '$region'),\" >> $local_settings"
   done
   sudo sh -c "echo \" ]\" >> $local_settings"
   sudo service apache2 restart
   
  sudo pip install -e git+https://github.com/mfaraji/django_openstack_auth#egg=openstack_auth
fi

# Add tcp/22 to default security group
source $TOP_DIR/tests/add-defaults

# Remove EXT_NET_IFACE from any bridges it may be connected to
CURR_OVS=`sudo ovs-vsctl port-to-br $EXT_NET_IFACE`
if [[ ! -z "$CURR_OVS" ]]; then
  sudo ovs-vsctl del-port $CURR_OVS $EXT_NET_IFACE
fi

# Add interface to public bridge and remove its IP
sudo ifconfig $EXT_NET_IFACE up
sudo ip addr flush dev $EXT_NET_IFACE

sudo ovs-vsctl --no-wait -- --may-exist add-port $PUBLIC_BRIDGE $EXT_NET_IFACE

#. $TOP_DIR/ryu_port_reg.sh

echo "Finished regular stack.sh"

