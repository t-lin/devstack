#!/bin/bash
sudo /etc/init.d/openvswitch-switch stop
sleep 5
sudo rm /etc/openvswitch/conf.db
sudo ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
sleep 5
sudo /etc/init.d/openvswitch-switch start
