#!/bin/sh
#HOST=`hostname -f`

#BMC_HOST=bmc-tr-edge-1.savinetwork.ca
#NOVA_BIN_DIR=/usr/local/bin
#BM_CONF=/etc/nova-bm
HOST=$BMC_HOST

# Please change parameters according to your bare-metal machine
node_id_atom=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST  --cpus 1 --memory_mb=4096 --local_gb=60 --pm_address="10.10.30.6" --pm_user="a,.1.3.6.1.4.1.21728.3.2.1.1.4.0,.1.3.6.1.4.1.21728.3.2.1.1.3.0" --pm_password="savi" --terminal_port=0 --prov_mac_address=00:30:18:a2:99:cf --type=i686)
node_id_asus=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 1 --memory_mb=16392 --local_gb=60 --pm_address="10.10.30.6" --pm_user="a,.1.3.6.1.4.1.21728.3.2.1.1.4.4,.1.3.6.1.4.1.21728.3.2.1.1.3.4" --pm_password="savi" --terminal_port=0 --prov_mac_address=10:bf:48:83:5a:cb --type=x86_64)
#node_id_volume=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 1 --memory_mb=4096 --local_gb=60 --pm_address="10.10.30.6" --pm_user=".1.3.6.1.4.1.21728.3.2.1.1.4.1,.1.3.6.1.4.1.21728.3.2.1.1.3.1" --pm_password="savi" --terminal_port=0 --prov_mac_address=00:14:22:44:16:22 --type=i686)
#node_id_cluster_1=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.1,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.1,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.1" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:DE:10 --type=i686)
node_id_cluster_2=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.2,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.2,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.2" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:E0:02 --type=i686)
node_id_cluster_3=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.3,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.3,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.3" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:95:02 --type=i686)
#node_id_cluster_4=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.4,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.4,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.4" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:DF:E4 --type=i686)
node_id_cluster_5=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.5,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.5,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.5" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:DF:DE --type=i686)
node_id_cluster_6=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.6,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.6,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.6" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:E0:7E --type=i686)
node_id_cluster_8=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.8,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.8,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.8" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:E0:06 --type=i686)
node_id_cluster_11=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.11,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.11,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.11" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:DA:E6 --type=i686)
node_id_cluster_12=$( $NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  node create --host $HOST --cpus 4 --memory_mb=2048 --local_gb=40 --pm_address="192.168.70.31" --pm_user="b,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.7.12,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.8.12,.1.3.6.1.4.1.2.3.51.2.22.1.6.1.1.4.12" --pm_password="savi1" --terminal_port=0 --prov_mac_address=00:09:6B:B5:DF:2A --type=i686)

# Please change parameters according to your bare-metal machine
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_asus --mac_address=68:05:CA:01:39:C3 --datapath_id=010010010073 --port_no=22
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_atom --mac_address=00:30:18:a2:99:d0 --datapath_id=010010010073 --port_no=20
#$NOVA_BIN_DIR/nova-bm-manage interface create --node_id=$node_id --mac_address=00:15:17:73:06:83 --datapath_id=0x0 --port_no=0
#$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_volume --mac_address=90:E2:BA:25:35:34 --datapath_id=0x010010010073 --port_no=10
#$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_1 --mac_address=00:09:6B:B5:DE:11 --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_2 --mac_address=00:09:6B:B5:E0:03 --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_3 --mac_address=00:09:6B:B5:95:03 --datapath_id=0x010010010073 --port_no=35
#$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_4 --mac_address=00:09:6B:B5:DF:E5 --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_5 --mac_address=00:09:6B:B5:DF:DF --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_6 --mac_address=00:09:6B:B5:E0:7F --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_8 --mac_address=00:09:6B:B5:E0:07 --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_11 --mac_address=00:09:6B:B5:DA:E7 --datapath_id=0x010010010073 --port_no=35
$NOVA_BIN_DIR/nova-bm-manage --config-dir=$BM_CONF  interface create --node_id=$node_id_cluster_12 --mac_address=00:09:6B:B5:DF:2B --datapath_id=0x010010010073 --port_no=35

#0800275BC2F5
#0800274C35B6
#90:e2:ba:25:35:34
