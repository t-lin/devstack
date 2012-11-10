nova boot --flavor m1.tiny --image $OS_REGION_NAME-cirros-0.3.0-x86_64-uec --security_groups default --key_name key1 $OS_REGION_NAME-server$1
nova list
sudo virsh list
